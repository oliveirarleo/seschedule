defmodule Seschedule.Handlers.Start do
  alias Seschedule.Handlers.Search.Texts

  @doc """
  This is the handler for the start command. It should simply send a message to the user about the bot.
  """
  @spec start(String.t() | integer()) :: :ok
  def start(chat_id) do
    {:ok, _message} =
      Telegex.send_message(
        chat_id,
        """
        *Olá,*
        #{Texts.clean_text_for_markdown("Eu sou um bot não oficial de eventos do SESC, dê uma olhada nos meus comandos no menu.")}
        """,
        parse_mode: "MarkdownV2"
      )

    :ok
  end
end
