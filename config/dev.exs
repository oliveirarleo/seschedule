import Config

config :seschedule,
  webhook_url: "https://sescheduledev.disccat.com/updates_hook",
  server_port: 9884

import_config "dev.secret.exs"
