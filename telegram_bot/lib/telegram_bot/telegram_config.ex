defmodule TelegramBot.TelegramConfig do
  use GenServer

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  @impl true
  def init(stack) do
    domain = Application.fetch_env!(:telegram_bot, :webhook_url)
    token = Telegex.Global.token()

    Telegex.set_webhook("#{domain}/webhook/#{token}",
      allowed_updates: ["message", "poll", "callback_query"]
    )

    Telegex.set_my_commands(
      [
        %Telegex.Type.BotCommand{
          command: "eventos",
          description: "Veja os últimos eventos do SESC"
        },
        %Telegex.Type.BotCommand{command: "lembrete", description: "Crie um lembrete para um evento"}
      ],
      language_code: "pt"
    )

    Telegex.set_my_commands(
      [
        %Telegex.Type.BotCommand{command: "events", description: "See all latests SESC events"},
        %Telegex.Type.BotCommand{command: "remind", description: "Remind me of an event"}
      ],
      language_code: "en"
    )

    {:ok, stack}
  end
end
