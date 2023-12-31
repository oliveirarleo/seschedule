# Seschedule

A bot for telegram that searches [SESC](https://www.sescsp.org.br/) events and reminds about them.

## Using in dev environment

  * Run `mix setup` to install and setup dependencies
  * Install ngrok and run `ngrok http 8443`
  * Update `dev.exs` and `dev.secret.exs` with your new url and token, example:

  ```elixir
  config :seschedule, webhook_url: "https://long-ngrok-url.com" # on dev.exs
  config :telegex, token: "123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11" # on dev.secret.exs
  ```
  > Tip: You can create a fixed domain in ngrok in the [domain page](https://dashboard.ngrok.com/cloud-edge/domains)

  * Start server with inside IEx with `iex -S mix`


## Deploying in fly.io

  * Use this `fly.toml` with `fly apps create --name {{yourappname}}` to create an app
  * Set the correct secrets:
  ```elixir
  config :seschedule, webhook_url: "https://{{yourappname}}.fly.dev" # on prod.exs
  config :telegex, token: "{{bot-token}}" # on prod.secret.exs
  ```
  * Run `fly deploy`
  > Tip: `fly scale count 1`, if you want to have only one machine working at a time



## TODO:

In order of relevance.

### Tests:

Create more doctests and tests.
* In particular it'll be nice to test if `Texts` `places`, `categories`, and `dates` matches with `protobufs`.
* We will most likely need [Mox](https://hexdocs.pm/mox/Mox.html).

### Docs

* Ensure docs for every module and method.
* Generate docs page.

### CI

Ensure tests and docs are complete via CI.

### Join "Grande São Paulo" requests

* Use a simple [Agent](https://hexdocs.pm/elixir/1.16.0/Agent.html) to manage the events, then our internal search can be more sofisticated.
*Possibly save them using sqlite3 + Ecto.

### Give support for SESCs in other states

Currently the search is limited to SESC SP, although there is a lot of SESC units in SP, there are tons in other states.
* We must find what are the other SESCs websites and reverse engineer their APIs.
* We must include them as options to search and possibly change the search flow a little bit.

### Remind:

Create workflow for remind functionallity.

### I18n:

Give support for english, spanish and french.
