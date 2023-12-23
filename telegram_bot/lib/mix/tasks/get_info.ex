defmodule Mix.Tasks.GetInfo do
  use Mix.Task

  @shortdoc "Give a short salutation"

  def run(_) do
    api_reference =
      File.read!("/home/leo/git/p/seschedule/telegram_bot/references/api_response.json")
      |> Jason.decode!()

    activities =
      api_reference["body"]["atividade"]
      |> Enum.filter(&(&1 != nil))

    grouped_categories =
      activities
      |> Enum.flat_map(& &1["categorias"])
      |> Enum.group_by(fn category -> category["link"] end)

    categories =
      Map.keys(grouped_categories)
      |> Enum.map(fn category_link ->
        "/categorias-atividades/" <> category = category_link
        category
      end)

    File.write(
      "/home/leo/git/p/seschedule/telegram_bot/references/categories.json",
      Jason.encode!(categories, pretty: true)
    )

    grouped_places =
      activities
      |> Enum.flat_map(& &1["unidade"])
      |> Enum.group_by(fn place ->
        case place["link"] do
          nil -> "online"
          "/unidades/" <> place -> place
          other -> other
        end
      end)

    places =
      Map.keys(grouped_places)

    File.write(
      "/home/leo/git/p/seschedule/telegram_bot/references/places.json",
      Jason.encode!(places, pretty: true)
    )
  end
end
