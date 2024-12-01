defmodule Seschedule.HookHandler do
  use Telegex.Hook.GenHandler

  @commands_config %{
    "start" => %{
      bot_command: %Telegex.Type.BotCommand{
        command: "start",
        description: "Descrição do bot"
      },
      handler: &Seschedule.Handlers.Start.start/1
    },
    "proximos_eventos" => %{
      bot_command: %Telegex.Type.BotCommand{
        command: "proximos_eventos",
        description: "Veja os últimos eventos do SESC"
      },
      handler: &Seschedule.Handlers.NextEvents.next_events/1
    },
    "sortear" => %{
      bot_command: %Telegex.Type.BotCommand{
        command: "sortear",
        description: "Sortear alguns eventos do SESC"
      },
      handler: &Seschedule.Handlers.Random.random_events/1
    },
    "busca" => %{
      bot_command: %Telegex.Type.BotCommand{
        command: "busca",
        description: "Busca avançada de eventos do SESC"
      },
      handler: &Seschedule.Handlers.Search.search/1
    },
    "lembrete" => %{
      bot_command: %Telegex.Type.BotCommand{
        command: "lembrete",
        description: "Crie um lembrete para um evento"
      },
      handler: &Seschedule.Handlers.Remider.remind/1
    }
  }

  @doc """
  Registers webhook and commands on boot
  """
  @spec on_boot :: Telegex.Hook.Config.t()
  @impl true
  def on_boot do
    # read some parameters from your env config
    webhook_url = Application.get_env(:seschedule, :webhook_url)
    server_port = Application.get_env(:seschedule, :server_port)

    {:ok, true} = Telegex.delete_webhook()
    {:ok, true} = Telegex.set_webhook(webhook_url)

    Logger.info("Domains set to #{webhook_url} on port #{server_port}")

    commands = @commands_config |> Enum.map(fn {_k, v} -> v.bot_command end)

    {:ok, true} = Telegex.set_my_commands(commands, language_code: "pt")
    {:ok, true} = Telegex.set_my_commands(commands, language_code: "en")

    %Telegex.Hook.Config{server_port: server_port}
  end

  @doc """
  Handles all possible initial commands
  """
  @impl true
  @spec on_update(Telegex.Type.Update.t()) :: :ok
  def on_update(%Telegex.Type.Update{} = update) do
    case update do
      %Telegex.Type.Update{
        message: %Telegex.Type.Message{
          entities: [%Telegex.Type.MessageEntity{type: "bot_command"}],
          chat: %{id: chat_id},
          text: "/" <> command
        }
      } ->
        case @commands_config |> Map.fetch(command) do
          {:ok, %{handler: handler}} ->
            handler.(chat_id)

          :error ->
            Telegex.send_message(
              chat_id,
              "Não reconheço o comando #{command}",
              parse_mode: "MarkdownV2"
            )
        end

      %Telegex.Type.Update{
        callback_query: %Telegex.Type.CallbackQuery{
          id: callback_id,
          data: callback_data,
          message: %Telegex.Type.Message{
            message_id: message_id,
            chat: %Telegex.Type.Chat{
              id: chat_id
            }
          }
        }
      } ->
        Seschedule.Handlers.Search.handle_callback(
          callback_id,
          chat_id,
          message_id,
          callback_data
        )

      update ->
        Logger.warning("Fallback on update: #{inspect(update)}")
    end

    :ok
  end
end
