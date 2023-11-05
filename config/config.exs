import Config

config :seschedule,
  # in milliseconds
  period: 5 * 60 * 1000,
  base_url: "https://www.sescsp.org.br/wp-json/wp/v1/atividades/filter",
  server_port: 4000

config :telegex, caller_adapter: Finch, hook_adapter: Bandit

config :logger, :console, metadata: [:bot, :chat_id]

import_config "#{config_env()}.exs"
