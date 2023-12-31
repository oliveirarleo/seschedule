defmodule Seschedule.TelegramController do
  alias Seschedule.Api.SescSp
  require Logger
  import Seschedule.Handlers.Helpers

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          callback_query: Telegex.Type.CallbackQuery.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(_conn, %{
        "callback_query" => %{
          "id" => message_id,
          "data" => "p:" <> callback_data,
          "message" => %{"chat" => %{"id" => chat_id}}
        }
      }) do
    Logger.debug("In final #{message_id}")

    Task.async(fn -> Telegex.answer_callback_query(message_id) end)
    typing_action = Task.async(fn -> Telegex.send_chat_action(chat_id, "typing") end)

    num_take_events = Application.fetch_env!(:seschedule, :events_per_page)

    {activities, %{"value" => total_events}} =
      SescSp.get_events(
        data_final: when_,
        local: where,
        categoria: category,
        ppp: num_take_events,
        page: page
      )

    case activities do
      [] ->
        Telegex.send_message(
          chat_id,
          "*Pesquisa*\n" <>
            clean_text_for_markdown(
              "Local: #{where}\nCategoria: #{category}\nAté #{when_}\nNão encontrei nenhum evento para essa pesquisa."
            ),
          parse_mode: "MarkdownV2"
        )

      events ->
        num_events =
          if page <= div(total_events, num_take_events) do
            num_take_events
          else
            rem(total_events, num_take_events)
          end

        Telegex.send_message(
          chat_id,
          "*Pesquisa*\n" <>
            clean_text_for_markdown("""
            Local: #{if where == "", do: "Todos", else: where}
            Categoria: #{if category == "", do: "Todas", else: category}
            Até #{when_}
            Número de eventos encontrados #{total_events}#{if total_events > num_take_events do
              ".\nAqui estão #{num_events} eventos da página #{page}"
            end}:
            """),
          parse_mode: "MarkdownV2"
        )

        send_activities_messages(chat_id, events)

        if total_events / page > num_take_events do
          [_ | new_callback_params] = String.split(callback_data, "|")
          new_callback_data = Enum.join(["p:#{page + 1}" | new_callback_params], "|")

          Telegex.send_message(
            chat_id,
            "Para mais eventos, clique no botão abaixo:",
            parse_mode: "MarkdownV2",
            reply_markup: %Telegex.Type.InlineKeyboardMarkup{
              inline_keyboard: [
                [
                  %Telegex.Type.InlineKeyboardButton{
                    text: "Página #{page + 1}",
                    callback_data: new_callback_data
                  }
                ]
              ]
            }
          )
        end

        Task.await(typing_action)
    end
  end
end
