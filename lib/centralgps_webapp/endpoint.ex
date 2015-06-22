defmodule CentralGPSWebApp.Endpoint do
  use Phoenix.Endpoint, otp_app: :central_g_p_s_web_app

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :central_g_p_s_web_app, #gzip: false,
    only: ~w(css images fonts js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison,
    length: 3_000_000_000

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session,
    store: :cookie,
    key: "_centralgps_webapp_key",

    signing_salt: "oAPtYKsJ"

  plug :router, CentralGPSWebApp.Router
end
