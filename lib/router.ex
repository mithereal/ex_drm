defmodule Drm.Router do
  @moduledoc false
  use Plug.Router
  require EEx

  plug(Plug.Static,
    at: "/",
    from: :drm,
    only: ~w(application.js)
  )

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  EEx.function_from_file(:defp, :application_html, "lib/application.html.eex", [])

  get "/" do
    send_resp(conn, 200, application_html())
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
