defmodule CentralGPSWebApp.Client.MonitorController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.Repo.Utilities
  import CentralGPS.RestClient, only: [api_get_json: 3, api_post_json: 4]
  plug :action

  def index(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render conn, "monitor.html"
    end
  end

  def assets(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {status, res} = api_get_json "/monitor/client", session.auth_token, "C"
      json conn, res.body
    end
  end
#todo: find out WHY ITS NOT BRINGING ANY DATA?!?!?!?! :( 
  def checkpoint_mark(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {status, res} = api_get_json "/checkpoint/marks?init_at=2015-05-27&finish_at=2015-05-30", session.auth_token, "C"
      json conn, res.body
    end
  end

end
