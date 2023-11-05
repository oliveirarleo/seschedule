defmodule Seschedule.Telegram.Finch do
  @moduledoc """
  Finch adapter to Tesla telegram app
  """
  use Tesla

  adapter Tesla.Adapter.Finch, name: __MODULE__, receive_timeout: 40_000
end
