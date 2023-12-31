defmodule Seschedule.Handlers.Search.Result do
  require Logger
  import Seschedule.Handlers.Search.Texts
  alias Seschedule.Encoding.Events.SearchRequest
  alias Seschedule.I18n.Cldr

  defp text_from_activity(activity) do
    %{
      "titulo" => raw_title,
      "complemento" => raw_description,
      "link" => link,
      "categorias" => categories,
      "dataPrimeiraSessao" => first_session,
      "dataUltimaSessao" => last_session,
      "unidade" => place
    } = activity

    title = clean_text_for_markdown(raw_title)
    description = clean_text_for_markdown(raw_description)

    first_session = Cldr.sesc_date_to_string(first_session)
    last_session = Cldr.sesc_date_to_string(last_session)

    categories =
      categories
      |> Enum.map(
        &"[#{clean_text_for_markdown(&1["titulo"])}](https://www.sescsp.org.br#{&1["link"]})"
      )
      |> Enum.join(", ")

    place =
      place
      |> Enum.map(
        &"[#{clean_text_for_markdown(&1["name"])}](https://www.sescsp.org.br#{&1["link"]})"
      )
      |> Enum.join(" , ")

    """
    *[#{title}](https://www.sescsp.org.br#{link})*
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

  @spec send_activities_messages(integer(), list()) :: :ok
  def send_activities_messages(chat_id, activities) do
    for activity <- activities do
      text = text_from_activity(activity)
      Logger.info(text)

      %{"imagem" => image_link} = activity

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

  @spec prepare_search_args(atom(), atom(), atom()) ::
          {String.t(), String.t(), String.t()}
  def prepare_search_args(place, category, date) do
    place_for_api =
      SearchRequest.Place.descriptor().value
      |> Enum.find(&(String.to_atom(&1.name) == place))
      |> then(fn v -> v.number end)

    category_for_api =
      case category do
        :ALL_CATEGORIES -> ""
        category -> category |> Atom.to_string() |> String.downcase()
      end

    days_to_search =
      case date do
        :NEXT_WEEK -> 7
        :NEXT_MONTH -> 30
        :NEXT_3_MONTHS -> 90
      end

    date_for_api = Date.utc_today() |> Date.add(days_to_search) |> Date.to_string()

    {place_for_api, category_for_api, date_for_api}
  end
end
