defmodule Seschedule.Repo do
  use Ecto.Repo,
    otp_app: :seschedule,
    adapter: Ecto.Adapters.SQLite3
end
