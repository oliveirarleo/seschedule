defmodule Seschedule.Handlers.Random do
  require Logger
  alias Seschedule.Api.SescSp
  alias Seschedule.Handlers.Search.Result

  @doc """
  This is the handler for the random_events command. It should send a message with some random events.
  """
  @spec random_events(String.t() | integer()) :: :ok
  def random_events(chat_id) do
    Logger.info("In random: #{chat_id}")
    # Task.async(fn -> Telegex.send_chat_action(chat_id, "typing") end)

    {activities, %{"value" => total_events}} = SescSp.get_events(ppp: 500)

    num_events = Application.fetch_env!(:seschedule, :events_per_page)
    activities = Enum.take_random(activities, num_events)

    {:ok, _message} =
      Telegex.send_message(
        chat_id,
        "De #{total_events} eventos no próximo mês, sorteei estes #{num_events} daqui para você:"
      )

    Result.send_activities_messages(chat_id, activities)

    :ok
  end
end
