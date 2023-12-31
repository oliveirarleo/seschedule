defmodule Seschedule.Api.Storage do
  use Agent

  @spec start_link() :: {:error, any()} | {:ok, pid()}
  @spec start_link(map()) :: {:error, any()} | {:ok, pid()}
  def start_link(initial_value \\ %{}) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  @spec all() :: map()
  def all do
    Agent.get(__MODULE__, & &1)
  end

  @spec update(map()) :: :ok
  def update(new_events) do
    Agent.update(__MODULE__, &Map.merge(&1, new_events))
  end
end
