defmodule Seschedule.Handlers.Search.Places do
  alias Seschedule.Handlers.Search.Texts
  alias Seschedule.Encoding.Events.SearchRequest

  @doc """
  Gets reply markup (message menu) to send back to the user.
  """
  @spec reply_markup(any(), any(), any(), any(), integer()) ::
          Telegex.Type.InlineKeyboardMarkup.t()
  @spec reply_markup(any(), any(), any(), any(), integer(), pos_integer()) ::
          Telegex.Type.InlineKeyboardMarkup.t()
  @spec reply_markup(any(), any(), any(), any(), integer(), pos_integer(), pos_integer()) ::
          Telegex.Type.InlineKeyboardMarkup.t()
  def reply_markup(category, date, page, place_page, category_page, num_cols \\ 3, num_rows \\ 4) do
    places = Texts.places()

    inline_keyboard =
      places
      |> Enum.map(fn {place, text} ->
        %Telegex.Type.InlineKeyboardButton{
          text: text,
          callback_data:
            %SearchRequest{
              page: page,
              place_page: place_page,
              category: category,
              category_page: category_page,
              place: place,
              date: date
            }
            |> SearchRequest.encode()
            |> Base.encode64()
        }
      end)
      |> Enum.chunk_every(num_cols)
      |> Enum.slice(place_page * num_rows, num_rows)

    places_len = length(places)

    page_buttons =
      [
        {"Página anterior", rem(place_page - 1, ceil(places_len / (num_cols * num_rows)))},
        {"Próxima página", rem(place_page + 1, ceil(places_len / (num_cols * num_rows)))}
      ]
      |> Enum.map(fn {text, next_page} ->
        %Telegex.Type.InlineKeyboardButton{
          text: text,
          callback_data:
            %SearchRequest{
              page: page,
              place_page: next_page,
              category: category,
              category_page: category_page,
              place: :PLACE_NOT_SET,
              date: date
            }
            |> SearchRequest.encode()
            |> Base.encode64()
        }
      end)

    inline_keyboard =
      inline_keyboard ++ [page_buttons]

    %Telegex.Type.InlineKeyboardMarkup{
      inline_keyboard: inline_keyboard
    }
  end
end
