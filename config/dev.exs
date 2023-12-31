import Config

config :seschedule,
  webhook_url: "https://basilisk-right-puma.ngrok-free.app/updates_hook",
  server_port: 8443

import_config "dev.secret.exs"
