# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :seschedule,
  ecto_repos: [Seschedule.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :seschedule, SescheduleWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: SescheduleWeb.ErrorHTML, json: SescheduleWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Seschedule.PubSub,
  live_view: [signing_salt: "dKvgr4Fp"],
  server: true

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :seschedule, Seschedule.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :seschedule,
  sesc_api_url: "https://www.sescsp.org.br/wp-json/wp/v1/atividades/filter"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :seschedule,
  events_per_page: 5,
  categories: [
    all: "Todas",
    "artes-visuais": "artes visuais",
    "cinema-e-video": "cinema e vídeo",
    musica: "música",
    "musica-show": "shows de música",
    danca: "dança",
    teatro: "teatro",
    "acoes-para-cidadania": "ações para cidadania",
    alimentacao: "alimentação",
    circo: "circo",
    criancas: "crianças",
    empresas: "empresas",
    "esportes-e-atividade-fisica": "esporte e atividade física",
    "gestao-cultural": "gestão cultural",
    idosos: "Idosos",
    intergeracoes: "Intergerações",
    jovens: "Jovens",
    literatura: "literatura",
    "meio-ambiente": "meio ambiente",
    multilinguagem: "Multilinguagem",
    saude: "saúde",
    "tecnologias-e-artes": "tecnologias e artes",
    turismo: "turismo"
  ],
  places: [
    all: "Todas",
    "25": "Araraquara",
    "26": "Bauru",
    "27": "Bertioga",
    "28": "Birigui",
    "29": "Campinas",
    "30": "Catanduva",
    "31": "Jundiaí",
    "32": "Piracicaba",
    "33": "Presidente Prudente",
    "34": "Registro",
    "35": "Ribeirão Preto",
    "36": "Rio Preto",
    "37": "Santos",
    "42": "São Carlos",
    "40": "São José dos Campos",
    "38": "Sorocaba",
    "41": "Taubaté",
    "761": "14 Bis",
    "2": "24 de Maio",
    "43": "Avenida Paulista",
    "47": "Belenzinho",
    "48": "Bom Retiro",
    "49": "Campo Limpo",
    "50": "Carmo",
    "730": "Casa Verde",
    "51": "Centro de Pesquisa e Formação",
    "52": "CineSesc",
    "53": "Consolação",
    "54": "Florêncio de Abreu",
    "71": "Guarulhos",
    "55": "Interlagos",
    "56": "Ipiranga",
    "57": "Itaquera",
    "80": "Mogi das Cruzes",
    "58": "Osasco",
    "59": "Parque Dom Pedro II",
    "60": "Pinheiros",
    "61": "Pompeia",
    "62": "Santana",
    "63": "Santo Amaro",
    "64": "Santo André",
    "65": "São Caetano",
    "66": "Vila Mariana"
  ],
  sesc_filter_props: [
    "id",
    "titulo",
    "complemento",
    "categorias",
    "dataPrimeiraSessao",
    "dataUltimaSessao",
    "unidade",
    "link",
    "imagem",
    "cancelado",
    "qtdeIngressosWeb",
    "qtdeIngressosRede"
  ]
