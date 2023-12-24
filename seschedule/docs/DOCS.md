# Seschedule

## Starting

  * When `/start` is sent, we return a brief description of what I am:
  > Hi, I am a unnofficial bot that helps with Sesc events, please type one of the commands and I will walk you through.

## Searching for events

### Basic info
  * Send command to search events: `/eventos`
  * Next week events or Advanced search
  * Search parameters:
    * Where
    * Category
    * Period: Next 3 months, Next month, Next week

## API used

Information is fetched with the following endpoint: `https://www.sescsp.org.br/wp-json/wp/v1/atividades/filter`

Parameters used to search are:
```elixir
default_filter_params = [
      data_inicial: "2023-11-05",
      data_final: "2023-11-30",
      local: "",
      categoria: "musica-show",
      source: "null",
      ppp: 1000,
      page: 1,
      tipo: "atividade"
    ]
```

Relevant parameters received are:
```elixir
    relevant_props = [
      "id",
      "titulo", # title
      "complemento", # complement
      "categorias", # category
      "dataPrimeiraSessao", # first session date
      "dataUltimaSessao", # last session date
      "unidade", # unit
      "link", # link
      "cancelado", # canceled or not
      "qtdeIngressosWeb", # number of tickets web
      "qtdeIngressosRede" # number of tickets on sesc network
    ]
```