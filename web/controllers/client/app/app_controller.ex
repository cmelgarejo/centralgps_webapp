defmodule CentralGPSWebApp.Client.AppController do
  use CentralGPSWebApp.Web, :controller
  #import CentralGPS.Repo.Utilities
  #import CentralGPSWebApp
  plug :action

  def index(conn, _params) do
    user_data = get_session(conn, :user_data)
    if (user_data != nil) do
      render conn, "app.html"
    else
      redirect conn, to: login_path(Endpoint, :index)
    end
  end

end
