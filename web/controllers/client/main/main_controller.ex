defmodule CentralGPSWebApp.Client.MainController do
  use CentralGPSWebApp.Web, :controller
  plug :action

  def index(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else
      conn = conn
        |> assign(:__root_url, main_url(Endpoint, :index))
      render conn |> put_layout("main_template.html"), "main.html"
    end
  end

end
