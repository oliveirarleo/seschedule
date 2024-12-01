defmodule Seschedule.Handlers.Random do
  require Logger
  alias Seschedule.Handlers.Search.Result

  @doc """
  Gets random activities from API Cache
  """
  @spec get_random_activities() :: {list(), non_neg_integer()}
  def get_random_activities() do
    num_events = Application.fetch_env!(:seschedule, :events_per_page)

    activities =
      Seschedule.Api.Cache.get_events()
      |> Enum.take_random(num_events)
      |> Enum.map(fn {_, v} -> v end)

    {activities, num_events}
  end

  @doc """
  This is the handler for the random_events command. It should send a message with some random events.
  """
  @spec random_events(String.t() | integer()) :: :ok
  def random_events(chat_id) do
    {activities, num_events} = get_random_activities()

    {:ok, _message} =
      Telegex.send_message(
        chat_id,
        "Sorteei estes #{num_events} daqui para você:"
      )

    Result.send_activities_messages(chat_id, activities)

    :ok
  end
end
