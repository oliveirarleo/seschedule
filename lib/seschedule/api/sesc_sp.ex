defmodule Seschedule.Api.SescSp do
  @moduledoc """
  Documentation for `Seschedule.Api.SescSp`.
  """
  require Logger

  @doc """
  Make a request to sesc
  """
  def get_events(filter_params \\ []) do
    base_url = Application.fetch_env!(:seschedule, :sesc_api_url)

    default_filter_params = [
      data_inicial: Date.utc_today() |> Date.to_string(),
      data_final: Date.utc_today() |> Date.add(30) |> Date.to_string(),
      local: "",
      categoria: "",
      source: "null",
      ppp: 100,
      page: 1,
      tipo: "atividade"
    ]

    params = Keyword.merge(default_filter_params, filter_params)
    Logger.info("Requesting on #{base_url}, #{inspect(params)}")

    response = Req.get!(base_url, params: params)

    %{"atividade" => activities, "total" => total} = response.body

    relevant_props = [
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

    activities =
      activities |> Enum.filter(&(&1 != nil)) |> Enum.map(&Map.take(&1, relevant_props))

    {activities, total}
  end
end
