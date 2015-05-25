defmodule CentralGPSWebApp.Client.AssetController do
  use CentralGPSWebApp.Web, :controller
  #import CentralGPS.Repo.Utilities
  #import CentralGPSWebApp
  plug :action

  def index(conn, _params) do
    user_data = get_session(conn, :user_data)
    if (user_data != nil) do
      IO.puts "#{inspect user_data}"
      conn = conn
        |> assign(:language, user_data.language_code)
      render conn, "asset.html"
    else
      redirect conn, to: login_path(Endpoint, :index)
    end
  end

end
