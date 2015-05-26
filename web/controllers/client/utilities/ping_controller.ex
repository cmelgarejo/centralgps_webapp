defmodule CentralGPSWebApp.Client.PingController do
  use CentralGPSWebApp.Web, :controller
  plug :action

  def ping(conn, _params) do
    text conn, "pong"
  end
end
