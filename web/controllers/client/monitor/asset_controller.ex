defmodule CentralGPSWebApp.Client.AssetController do
  use CentralGPSWebApp.Web, :controller
  plug :action

  def index(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else
      render conn, "asset.html"
    end
  end

end
