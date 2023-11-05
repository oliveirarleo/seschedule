defmodule Seschedule.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    webhook_config = [
      host: Application.fetch_env!(:seschedule, :host),
      local_port: Application.fetch_env!(:seschedule, :port)
    ]

    bot_config = [
      token: Application.fetch_env!(:seschedule, :token),
      max_bot_concurrency: Application.fetch_env!(:seschedule, :max_concurrency)
    ]

    children = [
      Seschedule.Periodically,
      {Finch, name: Seschedule.Telegram.Finch},
      {Telegram.Webhook,
       config: webhook_config, bots: [{Seschedule.Telegram.Bot.Counter, bot_config}]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Seschedule.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
