import Config

config :seschedule, server_port: 8443

config :telegex, caller_adapter: {Finch, [receive_timeout: 5 * 1000]}, hook_adapter: Bandit

config :logger, :console, metadata: [:bot, :chat_id]

import_config "#{config_env()}.exs"
