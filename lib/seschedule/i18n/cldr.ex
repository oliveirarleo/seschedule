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

      iex> Seschedule.I18n.Cldr.sesc_date_to_date_time("2023-12-23T12:30")
      ~U[2023-12-23 12:30:00Z]

      iex> Seschedule.I18n.Cldr.sesc_date_to_date_time("2024-01-27T20:00")
      ~U[2024-01-27 20:00:00Z]

  """
  @spec sesc_date_to_date_time(String.t()) :: DateTime.t()
  def sesc_date_to_date_time(sesc_date) do
    # This time is on "America/Sao_Paulo", but we can avoid conversions by faking UTC
    {:ok, date, _} = DateTime.from_iso8601("#{sesc_date}:00Z")
    date
  end

  @doc ~S"""
  Should receive a sesc date as string and return a well formatted version

  ## Examples

      iex> Seschedule.I18n.Cldr.date_time_to_string("2023-12-23T12:30")
      "23/12/2023 12:30"

      iex> Seschedule.I18n.Cldr.date_time_to_string("2024-01-27T20:00")
      "27/01/2024 20:00"

  """
  @spec date_time_to_string(String.t()) :: String.t()
  def date_time_to_string(sesc_date) do
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
