defmodule Seschedule.Handlers.Random do
  require Logger
  alias Seschedule.Handlers.Search.Result

  @doc """
  This is the handler for the random_events command. It should send a message with some random events.
  """
  @spec random_events(String.t() | integer()) :: :ok
  def random_events(chat_id) do
    Logger.info("In random: #{chat_id}")

    activities = Seschedule.Api.Cache.get_events() |> Enum.map(fn {_, v} -> v end)

    num_events = Application.fetch_env!(:seschedule, :events_per_page)
    activities = Enum.take_random(activities, num_events)

    {:ok, _message} =
      Telegex.send_message(
        chat_id,
        "Sorteei estes #{num_events} daqui para você:"
      )

    Result.send_activities_messages(chat_id, activities)

    :ok
  end
end
