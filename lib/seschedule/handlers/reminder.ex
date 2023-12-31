defmodule Seschedule.Handlers.Remider do
  alias Seschedule.Handlers.Search.Texts
  @doc """
  This is the handler for the remind command. It should send a message back continuing the workflow for the remind command.
  """
  @spec remind(String.t() | integer()) :: :ok
  def remind(chat_id) do
    {:ok, _} =
      Telegex.send_message(
        chat_id,
        Texts.clean_text_for_markdown("Esta funcionalidade ainda não está disponível."),
        parse_mode: "MarkdownV2"
      )
    :ok
  end
end
