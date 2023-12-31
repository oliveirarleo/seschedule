import Config

config :seschedule, server_port: 8443

config :telegex, caller_adapter: {Finch, [receive_timeout: 5 * 1000]}, hook_adapter: Bandit

config :logger, :console, metadata: [:bot, :chat_id]

config :ex_cldr,
  default_locale: "pt",
  default_backend: Seschedule.I18n.Cldr

config :seschedule,
  events_per_page: 5,
  sesc_api_url: "https://www.sescsp.org.br/wp-json/wp/v1/atividades/filter"

import_config "#{config_env()}.exs"
