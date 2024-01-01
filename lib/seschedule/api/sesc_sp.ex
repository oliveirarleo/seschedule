defmodule Seschedule.Api.SescSp do
  @moduledoc """
  Documentation for `Seschedule.Api.SescSp`.
  """
  alias Seschedule.I18n.Cldr
  require Logger

  @doc """
  Make a request to sesc
  """
  @spec get_events(keyword()) :: {list(), integer()}
  def get_events(filter_params \\ []) do
    sesc_api_url = Application.fetch_env!(:seschedule, :sesc_api_url)

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
    Logger.info("Requesting on #{sesc_api_url}, #{inspect(params)}")

    response = Req.get!(sesc_api_url, params: params)

    %{"atividade" => activities, "total" => %{"value" => total}} = response.body

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
      "esgotado",
      "qtdeIngressosWeb",
      "qtdeIngressosRede"
    ]

    sesc_base_url = Application.fetch_env!(:seschedule, :sesc_base_url)

    activities =
      activities
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(&Map.take(&1, relevant_props))
      |> Enum.map(fn event ->
        %Seschedule.Api.Event{
          id: event["id"] |> Integer.to_string(),
          title: event["titulo"] |> String.trim(),
          first_session: Cldr.sesc_date_to_date_time(event["dataPrimeiraSessao"]),
          last_session: Cldr.sesc_date_to_date_time(event["dataUltimaSessao"]),
          link: "#{sesc_base_url}#{event["link"] |> String.trim()}",
          complement: event["complemento"] |> String.trim(),
          image_link: event["imagem"] |> String.trim(),
          unit:
            event["unidade"]
            |> Enum.map(
              &{&1["name"] || "Online" |> String.trim(),
               "#{sesc_base_url}#{&1["link"] || "" |> String.trim()}"}
            ),
          categories:
            event["categorias"]
            |> Enum.map(
              &{&1["titulo"] |> String.trim(), "#{sesc_base_url}#{&1["link"] |> String.trim()}"}
            ),
          cancelado: event["cancelado"] == "1",
          esgotado:
            event["esgotado"] == "1" ||
              (event["qtdeIngressosWeb"] == 0 && event["qtdeIngressosRede"] == 0),
          num_tickets_web: event["qtdeIngressosWeb"],
          num_tickets_local: event["qtdeIngressosRede"]
        }
      end)

    {activities, total}
  end
end
