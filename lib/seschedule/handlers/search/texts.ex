defmodule Seschedule.Handlers.Search.Texts do
  @doc """
  Get text for all places, the order of this list will set the order in the menu
  """
  @spec places() :: [{atom(), String.t()}]
  def places do
    [
      ALL_PLACES: "Todas",
      VINTE_E_QUATRO_DE_MAIO: "24 de Maio",
      ARARAQUARA: "Araraquara",
      BAURU: "Bauru",
      BERTIOGA: "Bertioga",
      BIRIGUI: "Birigui",
      CAMPINAS: "Campinas",
      CATANDUVA: "Catanduva",
      JUNDIAI: "Jundiaí",
      PIRACICABA: "Piracicaba",
      PRESIDENTE_PRUDENTE: "Presidente Prudente",
      REGISTRO: "Registro",
      RIBEIRAO_PRETO: "Ribeirão Preto",
      RIO_PRETO: "Rio Preto",
      SANTOS: "Santos",
      SOROCABA: "Sorocaba",
      SAO_JOSE_DOS_CAMPOS: "São José dos Campos",
      TAUBATE: "Taubaté",
      SAO_CARLOS: "São Carlos",
      AVENIDA_PAULISTA: "Avenida Paulista",
      BELENZINHO: "Belenzinho",
      BOM_RETIRO: "Bom Retiro",
      CAMPO_LIMPO: "Campo Limpo",
      CARMO: "Carmo",
      CENTRO_DE_PESQUISA_E_FORMACAO: "Centro de Pesquisa e Formação",
      CINESESC: "CineSesc",
      CONSOLACAO: "Consolação",
      FLORENCIO_DE_ABREU: "Florêncio de Abreu",
      INTERLAGOS: "Interlagos",
      IPIRANGA: "Ipiranga",
      ITAQUERA: "Itaquera",
      OSASCO: "Osasco",
      PARQUE_DOM_PEDRO_II: "Parque Dom Pedro II",
      PINHEIROS: "Pinheiros",
      POMPEIA: "Pompeia",
      SANTANA: "Santana",
      SANTO_AMARO: "Santo Amaro",
      SANTO_ANDRE: "Santo André",
      SAO_CAETANO: "São Caetano",
      VILA_MARIANA: "Vila Mariana",
      GUARULHOS: "Guarulhos",
      MOGI_DAS_CRUZES: "Mogi das Cruzes",
      CASA_VERDE: "Casa Verde",
      QUATORZE_BIS: "14 Bis"
    ]
  end

  @doc """
  Get text for all categories, the order of this list will set the order in the menu
  """
  @spec categories() :: [{atom(), String.t()}]
  def categories do
    [
      ALL_CATEGORIES: "Todas",
      MUSICA: "Musica",
      MUSICA_SHOW: "Shows de música",
      TEATRO: "Teatro",
      CINEMA_E_VIDEO: "Cinema e Vídeo",
      DANCA: "Dança",
      ALIMENTACAO: "Alimentação",
      ARTES_VISUAIS: "Artes Visuais",
      CIRCO: "Circo",
      LITERATURA: "Literatura",
      CRIANCAS: "Crianças",
      EMPRESAS: "Empresas",
      ESPORTES_E_ATIVIDADE_FISICA: "Esportes",
      GESTAO_CULTURAL: "Gestão cultural",
      ACOES_PARA_CIDADANIA: "Ações para cidadania",
      IDOSOS: "Idosos",
      INTERGERACOES: "Intergerações",
      JOVENS: "Jovens",
      MEIO_AMBIENTE: "Meio Ambiente",
      MULTILINGUAGEM: "Multilinguagem",
      SAUDE: "Saúde",
      TECNOLOGIAS_E_ARTES: "Tecnologias e artes",
      TURISMO: "Turismo"
    ]
  end

  @doc """
  Get text for all dates, the order of this list will set the order in the menu
  """
  @spec dates() :: [{atom(), String.t()}]
  def dates do
    [
      NEXT_WEEK: "Nesta semana",
      NEXT_MONTH: "Próximo mês",
      NEXT_3_MONTHS: "Próximos três meses"
    ]
  end

  @doc """
  Telegram's MarkdownV2 needs these characters with prefix "//"
  """
  def clean_text_for_markdown(text) do
    String.replace(
      text,
      [
        "_",
        "*",
        "[",
        "]",
        "(",
        ")",
        "~",
        "`",
        ">",
        "#",
        "+",
        "-",
        "=",
        "|",
        "{",
        "}",
        ".",
        "!"
      ],
      fn c -> "\\#{c}" end
    )
  end
end
