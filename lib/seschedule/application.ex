defmodule Seschedule.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, args) do
    dbg(args)
    children =
      case args do
        [env: :test] -> []
        _ -> [Seschedule.HookHandler]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Seschedule.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
