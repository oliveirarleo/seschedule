# Seschedule

A bot for telegram

## Using in dev environment

  * Run `mix setup` to install and setup dependencies
  * Inspired by [this guide](https://ohanhi.com/phoenix-ssl-localhost), create your self-signed cert and keys:
  ```bash
  mkdir priv/migrations
  mkdir priv/keys
  cd priv/keys
  # generate key
  openssl genrsa -out localhost.key 2048
  # generate cert
  openssl req -new -x509 -key localhost.key -out localhost.cert -days 3650 -subj /CN=localhost
  ```
  * Install ngrok and run `ngrok http https://localhost:8443`
  * Update config.exs with your new url, example: `config :seschedule, webhook_url: "https://0dab-177-121-209-54.ngrok-free.app"`
  * Start Phoenix endpoint with inside IEx with `iex -S mix`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
