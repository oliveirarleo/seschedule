defmodule Mix.Tasks.FetchSescData do
  use Mix.Task

  @shortdoc "Fetch SESC API and save the files as references"
  @impl Mix.Task
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:req)

    sesc_api_url = Application.fetch_env!(:seschedule, :sesc_api_url)

    response =
      Req.get!(sesc_api_url,
        params: [
          data_inicial: Date.utc_today() |> Date.to_string(),
          data_final: Date.utc_today() |> Date.add(350) |> Date.to_string(),
          local: "",
          categoria: "",
          source: "null",
          ppp: 10000,
          page: 1,
          tipo: "atividade"
        ]
      )

    File.write(
      "/home/leo/git/p/seschedule/seschedule/references/api_response_body.json",
      Jason.encode!(response.body, pretty: true)
    )

    smap = Map.from_struct(response)

    File.write(
      "/home/leo/git/p/seschedule/seschedule/references/api_response.json",
      Jason.encode!(smap, pretty: true)
    )
  end
end
