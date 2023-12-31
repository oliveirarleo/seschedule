import Config

config :seschedule,
  webhook_url: "https://seschedule.fly.dev/updates_hook",
  server_port: 8443

import_config "prod.secret.exs"
