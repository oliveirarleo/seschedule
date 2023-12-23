defmodule TelegramBot.SESCAPI do
  @moduledoc """
  Documentation for `TelegramBot.SESCAPI`.
  """

  @doc """
  Make a request to sesc

  ## Examples

      iex> Seschedule.{:req, "~> 0.4.0"}()
      :ok

  """
  def get(filter_params \\ []) do
    base_url = Application.fetch_env!(:telegram_bot, :sesc_api_url)

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

    response = Req.get!(base_url, params: params)

    %{"atividade" => activities, "total" => total} = response.body

    relevant_props = Application.fetch_env!(:telegram_bot, :sesc_filter_props)

    activities =
      activities |> Enum.filter(&(&1 != nil)) |> Enum.map(&Map.take(&1, relevant_props))

    {activities, total}
  end
end
