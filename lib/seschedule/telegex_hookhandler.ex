defmodule Seschedule.HookHandler do
  use Telegex.Hook.GenHandler

  @impl true
  def on_boot do
    # read some parameters from your env config
    webhook_url = Application.get_env(:seschedule, :webhook_url)
    server_port = Application.get_env(:seschedule, :server_port)
    # delete the webhook and set it again
    dbg(webhook_url)
    dbg(server_port)

    {:ok, true} = Telegex.delete_webhook()
    {:ok, true} = Telegex.set_webhook(webhook_url)

    %Telegex.Hook.Config{server_port: server_port}
  end

  @impl true
  @spec on_update(Telegex.Type.Update.t()) :: :ok | Telegex.Chain.result()
  def on_update(%Telegex.Type.Update{
        message: %Telegex.Type.Message{
          chat: %{id: chat_id},
          text: text
        }
        # update_id: update_id
      }) do
    # consume the update
    dbg(chat_id)
    dbg(text)
    Telegex.send_message(chat_id, "you've sent me #{text}")
  end
end
