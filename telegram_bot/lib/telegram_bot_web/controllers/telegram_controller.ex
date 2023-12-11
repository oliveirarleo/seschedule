defmodule TelegramBotWeb.TelegramController do
  use TelegramBotWeb, :controller

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          message: Telegex.Type.MessageEntity.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{"message" => command}) do
    message = "Your message is " <> get_in(command, ["text"])
    chat_id = get_in(command, ["chat", "id"])

    Telegex.send_message(chat_id, "#{message} *bold text*
    __underline__
    ~strikethrough~
    ||spoiler||
    *bold _italic bold ~italic bold strikethrough ||italic bold strikethrough spoiler||~ __underline italic bold___ bold*
    [inline URL](http://www.example.com/)
    [inline mention of a user](tg://user?id=123456789)
    ![👍](tg://emoji?id=5368324170671202286)
    `inline fixed-width code`
    ```
    pre-formatted fixed-width code block
    ```
    ```python
    pre-formatted fixed-width code block written in the Python programming language
    ```",
      parse_mode: "MarkdownV2",
      reply_markup: %Telegex.Type.InlineKeyboardMarkup{
        inline_keyboard: [
          [
            %Telegex.Type.InlineKeyboardButton{
              text: "oi",
              callback_data: "asdasdasd"
            }
          ]
        ]
      }
    )

    # %InlineKeyboardButton{
    #   text: to_string(text),
    #   callback_data: "verification:#{@data_vsn}:#{index}:#{verification_id}"
    # }

    # Telegex.set_chat_menu_button(chat_id)

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          callback_query: Telegex.Type.CallbackQuery.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{"callback_query" => callback_query}) do
    id = get_in(callback_query, ["id"])
    dbg(id)
    Task.async(fn -> Telegex.answer_callback_query(id) end)

    chat_id = get_in(callback_query, ["message", "chat", "id"])
    Telegex.send_message(chat_id, "Recebido")

    conn
    |> render(:update)
    |> halt
  end
end
