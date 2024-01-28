defmodule Seschedule.I18n.CldrTest do
  use ExUnit.Case, async: true
  doctest Seschedule.I18n.Cldr, only: [sesc_date_to_date_time: 1, date_time_to_string: 1]
end
