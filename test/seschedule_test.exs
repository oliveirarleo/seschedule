defmodule SescheduleTest do
  use ExUnit.Case
  doctest Seschedule

  import Config
  test "correctly gets data" do
    assert {:ok, _} = Seschedule.Request.get()
  end
end
