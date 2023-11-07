defmodule Seschedule.Router do
  require Logger
  use Plug.Router

  plug(ExGram.Plug)

  get "/" do
    Logger.info("Success")
    send_resp(conn, 200, "Welcome")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
