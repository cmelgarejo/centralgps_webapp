defmodule CentralGPSWebApp.Client.LoginController do
  use CentralGPSWebApp.Web, :controller
  #import CentralGPSWebApp
  plug :action

  def index(conn, _params) do
    render conn |> put_layout("oob.html"), "login.html"
  end

  def login(conn, _params) do
    json conn, %{ok: true, params: _params}
  end

end
