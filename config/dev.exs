import Config

config :ex_gram, :webhook,
  # array of strings
  # allowed_updates: ["message", "poll"],
  # string (file path)
  # certificate: "priv/cert/selfsigned.pem",
  # boolean
  # drop_pending_updates: false,
  # string
  # ip_address: "1.1.1.1",
  # integer
  max_connections: 50,
  # string
  secret_token: "1114444123",
  # string (only domain name)
  url: "localhost"

import_config "dev.secret.exs"
