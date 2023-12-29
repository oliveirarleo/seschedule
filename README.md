# Seschedule

A bot for telegram

## Using in dev environment

  * Run `mix setup` to install and setup dependencies
  * Run `mix phx.gen.cert` to generate certificates
  * Install ngrok and run `ngrok http https://localhost:8443`
  * Update dev.secret.exs with your new url and token, example:

  ```elixir
  config :seschedule, webhook_url: "https://long-ngrok-url.com"
  config :telegex, token: "{{bot-token}}"
  ```
  * Start Phoenix endpoint with inside IEx with `iex -S mix`


## Deploying in fly.io

  * Use this `fly.toml` with `fly apps create --name yourappname` to create an app
  * Set `SECRET_KEY_BASE` as a secret in your fly app: `flyctl secrets set SECRET_KEY_BASE={{mix phx.gen.secret to create this}}`
  * Set the correct secrets:
  ```elixir
  config :seschedule, webhook_url: "https://yourappname.fly.dev"
  config :telegex, token: "{{bot-token}}"
  ```
  * Run `fly deploy`
  * Recommended: `fly scale count 1`, no need for multiple machines


