defmodule CentralGPSWebApp.Client.PingController do
  use CentralGPSWebApp.Web, :controller

  def ping(conn, _) do
    text conn, "pong"
  end
end
