defmodule CentralGPSWebApp.Client.AssetsController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient, only: [api_get_json: 3, api_post_json: 4]
  plug :action

  def index(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {status, res} = api_get_json "/monitor/client", session.auth_token, "C"
      IO.puts "#{inspect res}"
      render conn, "assets.html"
    end
  end

end
