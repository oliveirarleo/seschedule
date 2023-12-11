defmodule TelegramBot.Repo do
  use Ecto.Repo,
    otp_app: :telegram_bot,
    adapter: Ecto.Adapters.SQLite3
end
