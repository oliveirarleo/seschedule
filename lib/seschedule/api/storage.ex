defmodule Seschedule.Api.Cache do
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: EventCache)
  end

  @impl true
  def init(_) do
    Logger.info("Init Cache")

    # Schedule work to be performed on start
    schedule_work(:timer.seconds(1))

    {:ok, %{}}
  end

  defp fetch_events() do
    {new_events, total} = Seschedule.Api.SescSp.get_events(ppp: 10000)
    Logger.info("Fetch successful, got #{total} events")

    new_events |> Map.new(fn event -> {event.id, event} end)
  end

  @impl true
  def handle_info(:work, state) do
    to_save = fetch_events()
    new_state = Map.merge(state, to_save)

    # Reschedule once more
    schedule_work()

    {:noreply, new_state}
  end

  defp schedule_work(time \\ :timer.minutes(10)) do
    Process.send_after(self(), :work, time)
  end

  @impl true
  def handle_call(:get_events, _from, state) do
    {:reply, state, state}
  end

  @spec get_events() :: %{String.t() => Seschedule.Api.Event.t()}
  def get_events() do
    GenServer.call(EventCache, :get_events)
  end
end
