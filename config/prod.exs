import Config

config :seschedule,
  webhook_url: "https://seschedule.disccat.com/updates_hook",
  server_port: 9885

import_config "prod.secret.exs"
