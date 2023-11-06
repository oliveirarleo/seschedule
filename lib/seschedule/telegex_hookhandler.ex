defmodule Seschedule.HookHandler do
  use Telegex.Hook.GenHandler

  @impl true
  def on_boot do
    # read some parameters from your env config
    env_config = Application.get_env(:seschedule, __MODULE__)
    # delete the webhook and set it again
    {:ok, true} = Telegex.delete_webhook()
    # set the webhook (url is required)
    {:ok, true} = Telegex.set_webhook(env_config[:webhook_url])
    # specify port for web server
    # port has a default value of 4000, but it may change with library upgrades
    %Telegex.Hook.Config{server_port: env_config[:server_port]}
    # you must return the `Telegex.Hook.Config` struct ↑
  end

  @impl true
  def on_update(update) do
    # consume the update
    :ok
  end
end
