defmodule Seschedule.Handlers.NextEvents do
  require Logger
  alias Seschedule.Handlers.Search.Result

  @spec next_events(String.t() | integer()) :: :ok
  @doc """
  This is the handler for the next_events command. It should send a telegram message with some of the next events.
  """
  def next_events(chat_id) do
    num_events = Application.fetch_env!(:seschedule, :events_per_page)

    activities =
      Seschedule.Api.Cache.get_events()
      |> Enum.take(num_events)
      |> Enum.map(fn {_, v} -> v end)
      |> Enum.sort_by(fn v -> v.first_session end)

    {:ok, _message} =
      Telegex.send_message(
        chat_id,
        "Estes são os próximos #{num_events} eventos:"
      )

    Result.send_activities_messages(chat_id, activities)

    :ok
  end
end
