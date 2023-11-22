defmodule Seschedule.Request do
  @moduledoc """
  Documentation for `Seschedule.Request`.
  """

  @doc """
  Make a request to sesc

  ## Examples

      iex> Seschedule.{:req, "~> 0.4.0"}()
      :ok

  """
  def get(filter_params \\ []) do
    base_url = Application.fetch_env!(:seschedule, :base_url)

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

    params = Keyword.merge(default_filter_params, filter_params)

    %{"atividade" => atividade} = Req.get!(base_url, params: params).body

    relevant_props = [
      "id",
      "titulo",
      "complemento",
      "categorias",
      "dataPrimeiraSessao",
      "dataUltimaSessao",
      "unidade",
      "link",
      "cancelado",
      "qtdeIngressosWeb",
      "qtdeIngressosRede"
    ]

    atividade = atividade |> Enum.map(&Map.take(&1, relevant_props))

    # dbg(atividade)
    atividade
  end
end
