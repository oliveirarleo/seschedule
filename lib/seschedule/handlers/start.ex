defmodule Seschedule.Handlers.Start do
  alias Seschedule.Handlers.Helpers

  @doc """
  This is the handler for the start command. It should simply send a message to the user about the bot.
  """
  @spec start(String.t() | integer()) :: :ok
  def start(chat_id) do
    Telegex.send_message(
      chat_id,
      """
      *Olá,*
      #{Helpers.clean_text_for_markdown("Eu sou um bot não oficial de eventos do SESC, de uma olhada nos meus comandos no menu.")}
      """,
      parse_mode: "MarkdownV2"
    )
    :ok
  end
end
