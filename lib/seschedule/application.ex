defmodule Seschedule.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    token = Application.fetch_env!(:ex_gram, :token)

    children = [
      Seschedule.Periodically,
      ExGram,
      {Plug.Cowboy, scheme: :http, plug: Seschedule.Router, options: [port: 4000]},
      {Seschedule.Bot, [method: :webhook, token: token]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Seschedule.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
