defmodule Seschedule.Handlers.Search do
  alias Seschedule.Handlers.Search.{Dates, Places, Categories, Texts, Result}
  alias Seschedule.Encoding.Events.SearchRequest
  require Logger

  @doc """
  It starts the search command flow by sending a message with the possible dates
  """
  @spec search(String.t() | integer()) :: :ok
  def search(chat_id) do
    {:ok, _message} =
      Telegex.send_message(
        chat_id,
        "Pra qual data você gostaria de buscar?",
        parse_mode: "MarkdownV2",
        reply_markup: Dates.reply_markup()
      )

    :ok
  end

  @doc """
  Receives raw callback data, decodes and processes search request.
  This will happen for fetching places and categories, and executing request.
  """
  @spec handle_callback(String.t(), String.t(), integer(), binary()) :: :ok
  def handle_callback(callback_id, chat_id, message_id, callback_data) do
    decoded =
      callback_data
      |> Base.decode64!()
      |> SearchRequest.decode()

    Logger.info(
      "Received callback with #{inspect(chat_id)} and #{inspect(callback_data)}, decoded: #{inspect(decoded)}"
    )

    answer = Task.async(fn -> {:ok, true} = Telegex.answer_callback_query(callback_id) end)

    handle_search_request(chat_id, message_id, decoded)

    Task.await(answer)

    :ok
  end

  @doc """
  Handle callback for when place is not set.
  Depending on the parameter match:
  * Edits the previous message and set the menu to choose place.
  * Edits the previous message and set the menu to choose category.
  * Edits the previous message with the parameters of the request.
  * Calls SESC API and display the events.
  """
  @spec handle_search_request(String.t(), integer(), SearchRequest.t()) :: :ok
  def handle_search_request(chat_id, message_id, %SearchRequest{
        place: :PLACE_NOT_SET,
        place_page: place_page,
        category: category,
        category_page: category_page,
        date: date,
        page: page
      }) do
    Logger.info("In place: #{chat_id}")

    {:ok, _message} =
      Telegex.edit_message_text(
        "Selecione a unidade do SESC que gostaria de buscar:",
        chat_id: chat_id,
        message_id: message_id,
        reply_markup: Places.reply_markup(category, date, page, place_page, category_page)
      )

    :ok
  end

  def handle_search_request(chat_id, message_id, %SearchRequest{
        category: :CATEGORY_NOT_SET,
        place: place,
        place_page: place_page,
        category_page: category_page,
        date: date,
        page: page
      }) do
    Logger.info("In category: #{chat_id}")

    {:ok, _message} =
      Telegex.edit_message_text(
        "Selecione a categoria que gostaria de buscar:",
        chat_id: chat_id,
        message_id: message_id,
        reply_markup: Categories.reply_markup(place, date, page, place_page, category_page)
      )

    :ok
  end

  def handle_search_request(chat_id, message_id, %SearchRequest{
        place: place,
        place_page: place_page,
        category: category,
        category_page: category_page,
        date: date,
        page: page
      }) do
    {:ok, _message} =
      Telegex.edit_message_text(
        "*Pesquisa*\n" <>
          Texts.clean_text_for_markdown("""
          Local: #{Texts.places() |> Keyword.fetch!(place)}
          Categoria: #{Texts.categories() |> Keyword.fetch!(category)}
          Quando: #{Texts.dates() |> Keyword.fetch!(date)}
          Página: #{page}
          """),
        chat_id: chat_id,
        message_id: message_id,
        parse_mode: "MarkdownV2",
        reply_markup: %Telegex.Type.InlineKeyboardMarkup{
          inline_keyboard: []
        }
      )

    {place_for_api, category_for_api, date_for_api} =
      Result.prepare_search_args(place, category, date)

    Logger.info(
      "Request with #{chat_id}, #{message_id} place: #{place_for_api} #{place_page}, category: #{category_for_api} #{category_page}, date: #{date_for_api}, page: #{page}"
    )

    typing_action = Task.async(fn -> Telegex.send_chat_action(chat_id, "typing") end)

    num_take_events = Application.fetch_env!(:seschedule, :events_per_page)

    {activities, total_events} =
      Seschedule.Api.SescSp.get_events(
        data_final: date_for_api,
        local: place_for_api,
        categoria: category_for_api,
        ppp: num_take_events,
        page: page
      )

    case activities do
      [] ->
        Telegex.send_message(
          chat_id,
          Texts.clean_text_for_markdown("Não encontrei nenhum evento para essa pesquisa."),
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
          Texts.clean_text_for_markdown("""
          Número de eventos encontrados #{total_events}#{if total_events > num_take_events do
            ".\nAqui estão os eventos #{num_take_events * (page - 1) + 1} ... #{num_take_events * (page - 1) + num_events}"
          end}:
          """),
          parse_mode: "MarkdownV2"
        )

        Result.send_activities_messages(chat_id, events)

        # Next page, if there are more events to show
        if total_events / page > num_take_events do
          Telegex.send_message(
            chat_id,
            "Para mais eventos, clique no botão abaixo:",
            parse_mode: "MarkdownV2",
            reply_markup: %Telegex.Type.InlineKeyboardMarkup{
              inline_keyboard: [
                [
                  %Telegex.Type.InlineKeyboardButton{
                    text: "Página #{page + 1}",
                    callback_data:
                      %SearchRequest{
                        page: page + 1,
                        place_page: place_page,
                        category: category,
                        category_page: category_page,
                        place: place,
                        date: date
                      }
                      |> SearchRequest.encode()
                      |> Base.encode64()
                  }
                ]
              ]
            }
          )
        end
    end

    Task.await(typing_action)
  end
end
