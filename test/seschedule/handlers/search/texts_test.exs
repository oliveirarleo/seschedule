defmodule Seschedule.Handlers.Search.TextsTest do
  use ExUnit.Case, async: true

  doctest Seschedule.Handlers.Search.Texts

  test "date options match encoding" do
    from_text =
      Seschedule.Handlers.Search.Texts.dates()
      |> Enum.map(fn {key, _value} -> key end)
      |> Enum.sort()

    from_encoding =
      Seschedule.Encoding.Events.SearchRequest.Date.descriptor().value
      |> Enum.map(fn %{:name => name} -> String.to_atom(name) end)
      |> Enum.sort()

    assert from_text == from_encoding
  end

  test "categorie options match encoding" do
    from_text =
      Seschedule.Handlers.Search.Texts.categories()
      |> Enum.map(fn {key, _value} -> key end)
      |> Enum.sort()

    from_encoding =
      Seschedule.Encoding.Events.SearchRequest.Category.descriptor().value
      |> Enum.map(fn %{:name => name} -> String.to_atom(name) end)
      |> Enum.filter(&(&1 != :CATEGORY_NOT_SET))
      |> Enum.sort()

    assert from_text == from_encoding
  end


  test "place options match encoding" do
    from_text =
      Seschedule.Handlers.Search.Texts.places()
      |> Enum.map(fn {key, _value} -> key end)
      |> Enum.sort()

    from_encoding =
      Seschedule.Encoding.Events.SearchRequest.Place.descriptor().value
      |> Enum.map(fn %{:name => name} -> String.to_atom(name) end)
      |> Enum.filter(&(&1 != :PLACE_NOT_SET))
      |> Enum.sort()

    assert from_text == from_encoding
  end
end
