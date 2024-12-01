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
    case Telegex.edit_message_text(
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
         ) do
      {:error, error} -> Logger.warning("Unable to edit search message: #{inspect(error)}")
      _ -> :ok
    end

    typing_action = Task.async(fn -> Telegex.send_chat_action(chat_id, "typing") end)

    events =
      Seschedule.Api.Cache.get_events()
      |> Enum.map(fn {_, v} -> v end)
      |> Enum.sort_by(fn v -> v.first_session end)

    places =
      case place do
        :GRANDE_SP -> Seschedule.Handlers.Search.Places.grande_sp_places()
        place -> [place]
      end

    {activities, has_next_page, has_only_one_page, total_events, pagination_start, pagination_end} =
      Result.filter_events(events, places, category, date) |> Result.paginate_activities(page)

    _ =
      case activities do
        [] ->
          {:ok, _message} =
            Telegex.send_message(
              chat_id,
              Texts.clean_text_for_markdown("Não encontrei nenhum evento para essa pesquisa."),
              parse_mode: "MarkdownV2"
            )

        events ->
          {:ok, _message} =
            Telegex.send_message(
              chat_id,
              Texts.clean_text_for_markdown("""
              Número de eventos encontrados #{total_events}#{if has_only_one_page do
                ".\nAqui estão os eventos #{pagination_start} ... #{pagination_end}"
              end}:
              """),
              parse_mode: "MarkdownV2"
            )

          :ok = Result.send_activities_messages(chat_id, events)

          # Next page, if there are more events to show
          _message =
            if has_next_page do
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
