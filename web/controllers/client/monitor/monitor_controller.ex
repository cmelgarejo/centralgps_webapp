defmodule CentralGPSWebApp.Client.MonitorController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.Repo.Utilities
  import CentralGPS.RestClient
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

  def checkpoint_mark(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {status, res} = api_get_json "/checkpoint/marks", session.auth_token, "C", _params
      json conn, res.body
    end
  end

end
