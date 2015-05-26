defmodule CentralGPSWebApp.Client.MainController do
  use CentralGPSWebApp.Web, :controller
  plug :action

  def index(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else
      conn = assign conn, :session, session
      render conn |> put_layout("main_template.html"), "main.html"
    end
  end

end
