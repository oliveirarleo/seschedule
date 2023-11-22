defmodule Seschedule.Periodically do
  @moduledoc """
  Module responsible for periodically do work, like a cron job.
  """
  use GenServer

  @doc """
  Define job function to be called
  """
  @spec job() :: any()
  def job do
    dbg(Seschedule.Request.get())
    dbg(Nadia.get_updates())
    dbg(Nadia.get_me())
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    job()
    schedule()
    {:ok, state}
  end

  def handle_info(:work, state) do
    job()
    schedule()
    {:noreply, state}
  end

  defp schedule() do
    period = Application.fetch_env!(:seschedule, :period)
    Process.send_after(self(), :work, period)
  end
end
