defmodule Seschedule.Handlers.Search.Result do
  require Logger
  import Seschedule.Handlers.Search.Texts
  alias Seschedule.Api.Event
  alias Seschedule.I18n.Cldr

  @spec filter_events_by_places([Event.t()], [atom()]) :: [Event.t()]
  def filter_events_by_places(events, places) do
    if Enum.find(places, fn place -> place == :ALL_PLACES end) == nil do
      places_for_search =
        places
        |> Enum.map(fn place ->
          case place do
            :VINTE_E_QUATRO_DE_MAIO -> "24-de-maio"
            :QUATORZE_BIS -> "14-bis"
            place -> place |> Atom.to_string() |> String.downcase() |> String.replace("_", "-")
          end
        end)

      # places_tuple comes from Seschedule.Api.Event.unit
      in_place_for_search =
        fn places_tuple ->
          {_, places_text} = places_tuple

          places_for_search
          |> Enum.find(fn place_for_search ->
            String.ends_with?(places_text, place_for_search)
          end)
        end

      events
      |> Enum.filter(fn v ->
        v.unit |> Enum.find(in_place_for_search) != nil
      end)
    else
      events
    end
  end

  @spec filter_events_by_category([Event.t()], atom()) :: [Event.t()]
  def filter_events_by_category(events, category) do
    if category == :ALL_CATEGORIES do
      events
    else
      category_for_search =
        category |> Atom.to_string() |> String.downcase() |> String.replace("_", "-")

      # category_tuple comes from Seschedule.Api.Event.categories
      in_category_for_search =
        fn category_tuple ->
          {_, category_text} = category_tuple
          String.ends_with?(category_text, category_for_search)
        end

      events
      |> Enum.filter(fn v ->
        v.categories |> Enum.find(in_category_for_search) != nil
      end)
    end
  end

  @spec filter_events_by_date([Event.t()], :NEXT_3_MONTHS | :NEXT_MONTH | :NEXT_WEEK) :: [
          Event.t()
        ]
  def filter_events_by_date(events, date) do
    now_in_brazil = DateTime.utc_now() |> DateTime.add(-3, :hour)

    before =
      case date do
        :NEXT_WEEK -> DateTime.add(now_in_brazil, 7, :day)
        :NEXT_MONTH -> DateTime.add(now_in_brazil, 30, :day)
        :NEXT_3_MONTHS -> DateTime.add(now_in_brazil, 90, :day)
      end

    events
    |> Enum.filter(fn v ->
      DateTime.after?(v.first_session, now_in_brazil) and
        DateTime.before?(v.first_session, before)
    end)
  end

  @spec filter_events([Seschedule.Api.Event.t()], [atom()], atom(), atom()) :: [
          Seschedule.Api.Event.t()
        ]
  def filter_events(events, places, category, date) do
    events = filter_events_by_date(events, date)
    events = filter_events_by_category(events, category)
    events = filter_events_by_places(events, places)
    events
  end

  @spec text_from_activity(Seschedule.Api.Event.t()) :: String.t()
  defp text_from_activity(activity) do
    title = clean_text_for_markdown(activity.title)
    description = clean_text_for_markdown(activity.complement)

    first_session =
      activity.first_session |> Cldr.DateTime.to_string!(format: :short)

    last_session =
      activity.last_session |> Cldr.DateTime.to_string!(format: :short)

    sesc_base_url = Application.fetch_env!(:seschedule, :sesc_base_url)

    categories =
      activity.categories
      |> Enum.map(fn {name, link} -> "[#{clean_text_for_markdown(name)}](#{link})" end)
      |> Enum.join(", ")

    place =
      activity.unit
      |> Enum.map(fn {name, link} -> "[#{clean_text_for_markdown(name)}](#{link})" end)
      |> Enum.join(", ")

    """
    *[#{title}](#{sesc_base_url}#{activity.link})*
    #{if "" != String.trim(description) do
      "#{description}\n"
    else
      ""
    end}#{categories}
    Primeira sessão: #{first_session}
    Última sessão: #{last_session}
    Unidade: #{place}
    """
  end

  @spec send_activities_messages(integer(), [Seschedule.Api.Event.t()]) :: :ok
  def send_activities_messages(chat_id, activities) do
    for activity <- activities do
      text = text_from_activity(activity)

      image_link = activity.image_link

      case Telegex.send_photo(
             chat_id,
             image_link,
             caption: text,
             parse_mode: "MarkdownV2"
           ) do
        # TODO: it does not support all pics:
        # * The photo must be at most 10 MB in size.
        # * The photo's width and height must not exceed 10000 in total.
        # * Width and height ratio must be at most 20.
        # That means we need to fetch the img and send as multipart.
        # For now we check if it fails, if it does, send a normal message without image
        {:error, error} ->
          Logger.info("""
          Error sending photo:
          link: #{image_link}
          #{text}
          #{inspect(error)}
          """)

          Telegex.send_message(
            chat_id,
            text,
            parse_mode: "MarkdownV2"
          )

        ok ->
          ok
      end
    end

    :ok
  end
end
