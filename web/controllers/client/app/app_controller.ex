defmodule CentralGPSWebApp.Client.AppController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.Repo.Utilities
  import CentralGPSWebApp
  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end

end
