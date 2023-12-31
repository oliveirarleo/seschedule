defmodule Seschedule.Handlers.NextEvents do
  require Logger
  alias Seschedule.Api.SescSp
  alias Seschedule.Handlers.Search.Result

  @spec next_events(String.t() | integer()) :: :ok
  @doc """
  This is the handler for the next_events command. It should send a telegram message with some of the next events.
  """
  def next_events(chat_id) do
    Logger.debug("In next_events #{chat_id}")

    num_events = Application.fetch_env!(:seschedule, :events_per_page)

    {activities, total_events} = SescSp.get_events(ppp: num_events)

    {:ok, _message} =
      Telegex.send_message(
        chat_id,
        "Encontrei #{total_events} eventos, estes são os próximos #{num_events} eventos:"
      )

    Result.send_activities_messages(chat_id, activities)

    :ok
  end
end
