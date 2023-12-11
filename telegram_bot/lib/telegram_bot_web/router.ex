defmodule TelegramBotWeb.Router do
  use TelegramBotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TelegramBotWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TelegramBotWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", TelegramBotWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:telegram_bot, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TelegramBotWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  pipeline :telegram do
    plug :accepts, ["json"]
    plug TelegramBot.BotToken

    plug Plug.Parsers,
      parsers: [:urlencoded, :json],
      json_decoder: {Jason, :decode!, [[keys: :atoms]]},
      pass: ["*/*"]
  end

  pipe_through :telegram

  scope "/webhook/:bot_token", TelegramBotWeb do
    post "/", TelegramController, :update
  end
end
