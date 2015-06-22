defmodule CentralGPSWebApp.Client.PingController do
  use CentralGPSWebApp.Web, :controller

  def ping(conn, _params) do
    text conn, "pong"
  end
end
