defmodule CentralGPSWebApp.PageController do
  use CentralGPSWebApp.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
