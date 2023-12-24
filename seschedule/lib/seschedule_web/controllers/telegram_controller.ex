defmodule SescheduleWeb.TelegramController do
  require Logger
  alias Seschedule.SESCAPI
  use SescheduleWeb, :controller

  # TODO: cleanup update functions
  # TODO: separate behavior for each flow in modules
  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          message: Telegex.Type.MessageEntity.t(),
          update_id: Integer
        }) :: Plug.Conn.t()

  def update(conn, %{
        "message" => %{
          "chat" => %{"id" => chat_id},
          "text" => "/start",
          "entities" => [%{"type" => "bot_command"}]
        }
      }) do
    Telegex.send_message(
      chat_id,
      """
      *Olá,*
      #{clean_text_for_markdown("Eu sou um bot não oficial de eventos do SESC, de uma olhada nos meus comandos no menu.")}
      """,
      parse_mode: "MarkdownV2"
    )

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          message: Telegex.Type.MessageEntity.t(),
          update_id: Integer
        }) :: Plug.Conn.t()

  def update(conn, %{
        "message" => %{
          "chat" => %{"id" => chat_id},
          "text" => "/lembrete",
          "entities" => [%{"type" => "bot_command"}]
        }
      }) do
    Telegex.send_message(
      chat_id,
      """
      #{clean_text_for_markdown("Por enquanto não tenho suporte para esse comando.")}
      """,
      parse_mode: "MarkdownV2"
    )

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          message: Telegex.Type.MessageEntity.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{
        "message" => %{
          "chat" => %{"id" => chat_id},
          "text" => "/eventos",
          "entities" => [%{"type" => "bot_command"}]
        }
      }) do
    Telegex.send_message(
      chat_id,
      "Olá, quer dar uma olhada nos próximos eventos ou fazer uma pesquisa avançada?",
      parse_mode: "MarkdownV2",
      reply_markup: %Telegex.Type.InlineKeyboardMarkup{
        inline_keyboard: [
          [
            %Telegex.Type.InlineKeyboardButton{
              text: "Proximos eventos",
              callback_data: "next_events"
            }
          ],
          [
            %Telegex.Type.InlineKeyboardButton{
              text: "Estou com sorte",
              callback_data: "random"
            }
          ],
          [
            %Telegex.Type.InlineKeyboardButton{
              text: "Pesquisa avançada",
              callback_data: "advanced_search"
            }
          ]
        ]
      }
    )

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          callback_query: Telegex.Type.CallbackQuery.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{
        "callback_query" => %{
          "id" => message_id,
          "data" => "next_events",
          "message" => %{"chat" => %{"id" => chat_id}}
        }
      }) do
    Logger.debug("In next_events #{message_id}")
    Task.async(fn -> Telegex.answer_callback_query(message_id) end)

    # TODO: put as config
    num_events = Application.fetch_env!(:seschedule, :events_per_page)

    {activities, %{"value" => total_events}} =
      SESCAPI.get(ppp: num_events)

    Telegex.send_message(
      chat_id,
      "Encontrei #{total_events} eventos, estes são os próximos #{num_events} eventos:"
    )

    send_activities_messages(chat_id, activities)

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          callback_query: Telegex.Type.CallbackQuery.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{
        "callback_query" => %{
          "id" => message_id,
          "data" => "random",
          "message" => %{"chat" => %{"id" => chat_id}}
        }
      }) do
    Logger.debug("In random #{message_id}")
    Task.async(fn -> Telegex.answer_callback_query(message_id) end)
    Task.async(fn -> Telegex.send_chat_action(chat_id, "typing") end)

    {activities, %{"value" => total_events}} = SESCAPI.get(ppp: 10000)

    num_events = Application.fetch_env!(:seschedule, :events_per_page)
    activities = Enum.take_random(activities, num_events)

    Telegex.send_message(
      chat_id,
      "De #{total_events} eventos no próximo mês, sorteei estes #{num_events} daqui para você:"
    )

    send_activities_messages(chat_id, activities)

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          callback_query: Telegex.Type.CallbackQuery.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{
        "callback_query" => %{
          "id" => message_id,
          "data" => "advanced_search",
          "message" => %{"chat" => %{"id" => chat_id}}
        }
      }) do
    Logger.debug("In when #{message_id}")
    Task.async(fn -> Telegex.answer_callback_query(message_id) end)

    # TODO: use protobuf for callback_data
    Telegex.send_message(
      chat_id,
      "Pra qual data você gostaria de buscar?",
      parse_mode: "MarkdownV2",
      reply_markup: %Telegex.Type.InlineKeyboardMarkup{
        inline_keyboard: [
          [
            %Telegex.Type.InlineKeyboardButton{
              text: "Proxima semana",
              callback_data: "d:next_week"
            }
          ],
          [
            %Telegex.Type.InlineKeyboardButton{
              text: "Proximo mês",
              callback_data: "d:next_month"
            }
          ],
          [
            %Telegex.Type.InlineKeyboardButton{
              text: "Proximos 3 meses",
              callback_data: "d:next_three_months"
            }
          ]
        ]
      }
    )

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          callback_query: Telegex.Type.CallbackQuery.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{
        "callback_query" => %{
          "id" => message_id,
          "data" => "d:" <> callback_data,
          "message" => %{"chat" => %{"id" => chat_id}}
        }
      }) do
    Logger.debug("In where #{message_id}")
    Task.async(fn -> Telegex.answer_callback_query(message_id) end)

    # TODO: pagination
    Telegex.send_message(
      chat_id,
      "Em qual unidade do SESC você gostaria de buscar?",
      parse_mode: "MarkdownV2",
      reply_markup: %Telegex.Type.InlineKeyboardMarkup{
        inline_keyboard: get_places_inline_keyboard(callback_data)
      }
    )

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          callback_query: Telegex.Type.CallbackQuery.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{
        "callback_query" => %{
          "id" => message_id,
          "data" => "w:" <> callback_data,
          "message" => %{"chat" => %{"id" => chat_id}}
        }
      }) do
    Logger.debug("In cat #{message_id}")
    Task.async(fn -> Telegex.answer_callback_query(message_id) end)

    ci = get_categories_inline_keyboard(callback_data)
    Logger.debug(ci)

    Telegex.send_message(
      chat_id,
      "Qual categoria de eventos você gostaria de buscar?",
      parse_mode: "MarkdownV2",
      reply_markup: %Telegex.Type.InlineKeyboardMarkup{
        inline_keyboard: get_categories_inline_keyboard(callback_data)
      }
    )

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          callback_query: Telegex.Type.CallbackQuery.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{
        "callback_query" => %{
          "id" => message_id,
          "data" => "p:" <> callback_data,
          "message" => %{"chat" => %{"id" => chat_id}}
        }
      }) do
    Logger.debug("In final #{message_id}")

    Task.async(fn -> Telegex.answer_callback_query(message_id) end)
    Task.async(fn -> Telegex.send_chat_action(chat_id, "typing") end)

    {page, category, where, when_} = category_where_when("p:" <> callback_data)

    num_take_events = Application.fetch_env!(:seschedule, :events_per_page)

    {activities, %{"value" => total_events}} =
      SESCAPI.get(
        data_final: when_,
        local: where,
        categoria: category,
        ppp: num_take_events,
        page: page
      )

    case activities do
      [] ->
        Telegex.send_message(
          chat_id,
          "*Pesquisa*\n" <>
            clean_text_for_markdown(
              "Local: #{where}\nCategoria: #{category}\nAté #{when_}\nNão encontrei nenhum evento para essa pesquisa."
            ),
          parse_mode: "MarkdownV2"
        )

      events ->
        Telegex.send_message(
          chat_id,
          "*Pesquisa*\n" <>
            clean_text_for_markdown("""
            Local: #{if where == "", do: "Todos", else: where}
            Categoria: #{if category == "", do: "Todas", else: category}
            Até #{when_}
            Número de eventos encontrados #{total_events}#{if total_events > num_take_events do
              ".\nAqui estão #{num_take_events} eventos da página #{page}"
            end}:
            """),
          parse_mode: "MarkdownV2"
        )

        send_activities_messages(chat_id, events)

        if total_events / page > num_take_events do
          [_ | new_callback_params] = String.split(callback_data, "|")
          new_callback_data = Enum.join(["p:#{page + 1}" | new_callback_params], "|")

          Telegex.send_message(
            chat_id,
            "Para mais eventos, clique no botão abaixo:",
            parse_mode: "MarkdownV2",
            reply_markup: %Telegex.Type.InlineKeyboardMarkup{
              inline_keyboard: [
                [
                  %Telegex.Type.InlineKeyboardButton{
                    text: "Página #{page + 1}",
                    callback_data: new_callback_data
                  }
                ]
              ]
            }
          )
        end
    end

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          callback_query: Telegex.Type.CallbackQuery.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{
        "callback_query" => %{
          "id" => message_id,
          "data" => callback_data,
          "message" => %{"chat" => %{"id" => chat_id}}
        }
      }) do
    Logger.debug("In callback fallback #{message_id}")
    Task.async(fn -> Telegex.answer_callback_query(message_id) end)

    Telegex.send_message(
      chat_id,
      "Aconteceu um erro com #{callback_data}",
      parse_mode: "MarkdownV2"
    )

    conn
    |> render(:update)
    |> halt
  end

  @spec update(Plug.Conn.t(), %{
          bot_token: String.t(),
          callback_query: Telegex.Type.CallbackQuery.t(),
          update_id: Integer
        }) :: Plug.Conn.t()
  def update(conn, %{
        "message" => %{
          "chat" => %{"id" => chat_id},
          "text" => text,
        }
      }) do
    Logger.debug("In fallback #{chat_id}")

    Telegex.send_message(
      chat_id,
      "Não reconheço esse comando: #{text}",
      parse_mode: "MarkdownV2"
    )

    conn
    |> render(:update)
    |> halt
  end

  def category_where_when(callback_data) do
    ["p:" <> page, "c:" <> category, "w:" <> where, "d:" <> when_] =
      String.split(callback_data, "|")

    where_for_api =
      case where do
        "all" -> ""
        _ -> where
      end

    category_for_api =
      case category do
        "all" -> ""
        other -> other
      end

    days_to_search =
      case when_ do
        "next_week" -> 7
        "next_month" -> 30
        "next_three_months" -> 90
      end

    when_for_api = Date.utc_today() |> Date.add(days_to_search) |> Date.to_string()

    {page_for_api, _} = Integer.parse(page)
    {page_for_api, category_for_api, where_for_api, when_for_api}
  end

  @spec send_activities_messages(integer(), list()) :: list()
  defp send_activities_messages(chat_id, activities) do
    for %{
          "titulo" => raw_title,
          "complemento" => raw_description,
          "imagem" => image_link,
          "link" => link,
          "categorias" => categories,
          "dataPrimeiraSessao" => firstSession,
          "dataUltimaSessao" => lastSession,
          "unidade" => place
        } <- activities do
      title = clean_text_for_markdown(raw_title)
      description = clean_text_for_markdown(raw_description)

      categories =
        categories
        |> Enum.map(
          &"[#{clean_text_for_markdown(&1["titulo"])}](https://www.sescsp.org.br#{&1["link"]})"
        )
        |> Enum.join(", ")

      firstSession = clean_text_for_markdown(firstSession)
      lastSession = clean_text_for_markdown(lastSession)

      place =
        place
        |> Enum.map(
          &"[#{clean_text_for_markdown(&1["name"])}](https://www.sescsp.org.br#{&1["link"]})"
        )
        |> Enum.join(" , ")

      text = """
      *[#{title}](https://www.sescsp.org.br#{link})*
      #{description}
      #{categories}
      Primeira sessão: #{firstSession}
      Última sessão: #{lastSession}
      Unidade: #{place}
      """

      Telegex.send_photo(
        chat_id,
        image_link,
        caption: text,
        parse_mode: "MarkdownV2"
      )
    end
  end

  defp clean_text_for_markdown(text) do
    String.replace(
      text,
      [
        "_",
        "*",
        "[",
        "]",
        "(",
        ")",
        "~",
        "`",
        ">",
        "#",
        "+",
        "-",
        "=",
        "|",
        "{",
        "}",
        ".",
        "!"
      ],
      fn c -> "\\#{c}" end
    )
  end

  defp get_places_inline_keyboard(callback_data) do
    # TODO: pagination
    places = Application.fetch_env!(:seschedule, :places)

    Keyword.keys(places)
    |> Enum.map(fn places_id ->
      %Telegex.Type.InlineKeyboardButton{
        text: places[places_id],
        callback_data: "w:#{places_id}|d:" <> callback_data
      }
    end)
    |> Enum.chunk_every(3)
  end

  defp get_categories_inline_keyboard(callback_data) do
    # TODO: pagination
    categories = Application.fetch_env!(:seschedule, :categories)

    Keyword.keys(categories)
    |> Enum.map(fn categories_id ->
      %Telegex.Type.InlineKeyboardButton{
        text: categories[categories_id],
        callback_data: "p:1|c:#{categories_id}|w:#{callback_data}"
      }
    end)
    |> Enum.chunk_every(3)
  end
end
