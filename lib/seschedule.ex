defmodule Seschedule do
  @moduledoc """
  Documentation for `Seschedule`.
  """

  @doc """
  Make a request to sesc

  ## Examples

      iex> Seschedule.{:req, "~> 0.4.0"}()
      :ok

  """
  def get do
    base_url = Application.fetch_env!(:seschedule, :base_url)

    %{"atividade" => atividade} =
      Req.get!(base_url,
        params: [
          data_inicial: "2023-11-05",
          data_final: "2023-11-30",
          local: 43,
          categoria: "visuais-curso",
          source: "null",
          ppp: 1000,
          page: 1,
          tipo: "atividade"
        ]
      ).body

    atividade =
      atividade
      |> Enum.map(fn a ->
        Map.take(a, [
          "id",
          "titulo",
          "complemento",
          "dataPrimeiraSessao",
          "dataUltimaSessao",
          "unidade",
          "link",
          "cancelado",
          "qtdeIngressosWeb",
          "qtdeIngressosRede"
        ])
      end)

    dbg(atividade)
    :ok
  end
end
