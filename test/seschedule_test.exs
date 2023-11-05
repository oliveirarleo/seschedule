defmodule SescheduleTest do
  use ExUnit.Case
  doctest Seschedule

  test "correctly gets data" do
    assert Seschedule.get() == :ok
  end
end
