defmodule Seschedule.I18n.Cldr do
  @moduledoc """
  Define a backend module that will host our
  Cldr configuration and public API.

  Most function calls in Cldr will be calls
  to functions on this module.
  """
  use Cldr,
    locales: ["pt", "en"],
    default_locale: "pt",
    providers: [Cldr.Number, Cldr.Calendar, Cldr.DateTime]

  require Logger

  @doc ~S"""
  Should receive a sesc date as string and return a well formatted version

  ## Examples

      iex> Seschedule.I18n.Cldr.from_sesc_date("2023-12-23T12:30")
      "23/12/2023 12:30"

      iex> Seschedule.I18n.Cldr.from_sesc_date("2024-01-27T20:00")
      "27/01/2024 20:00"

  """
  @spec sesc_date_to_string(String.t()) :: String.t()
  def sesc_date_to_string(sesc_date) do
    # This time is on "America/Sao_Paulo", but we can avoid conversions by faking UTC
    case DateTime.from_iso8601("#{sesc_date}:00Z") do
      {:ok, date, _} ->
        date
        |> Seschedule.I18n.Cldr.DateTime.to_string!(format: :short)

      {:error, error} ->
        Logger.warning("Unable to parse sesc_date, #{inspect(error)}")
        sesc_date
    end
  end
end
