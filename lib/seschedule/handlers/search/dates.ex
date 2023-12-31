defmodule Seschedule.Handlers.Search.Dates do
  alias Seschedule.Handlers.Search.Texts
  alias Seschedule.Encoding.Events.SearchRequest

  @doc """
  Gets reply markup (message menu) to send back to the user.
  """
  @spec reply_markup() :: Telegex.Type.InlineKeyboardMarkup.t()
  def reply_markup() do
    inline_keyboard =
      Texts.dates()
      |> Enum.map(fn {date, text} ->
        [
          %Telegex.Type.InlineKeyboardButton{
            text: text,
            callback_data:
              %SearchRequest{
                page: 1,
                category: :CATEGORY_NOT_SET,
                place: :PLACE_NOT_SET,
                place_page: 0,
                category_page: 0,
                date: date
              }
              |> SearchRequest.encode()
              |> Base.encode64()
          }
        ]
      end)

    %Telegex.Type.InlineKeyboardMarkup{
      inline_keyboard: inline_keyboard
    }
  end
end
