defmodule CentralGPSWebApp.Client.MonitorController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient


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
      {api_status, res} = api_get_json "/monitor/client", session.auth_token, session.account_type
      if api_status == :ok do
        #do something! >:(
      else
        res = Map.put res, :body, %{ status: false, msg: res.reason } #HTTPoison.Error
      end
      #TODO: filter the data, like auth_token of each asset.
      json conn, res.body
    end
  end

  def record(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {_, res} = api_get_json "/monitor/client/record", session.auth_token, session.account_type, _params
      json conn, res.body
    end
  end

  def roadmap(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {_, res} = api_get_json "/monitor/client/roadmap", session.auth_token, session.account_type, _params
      json conn, res.body
    end
  end
end
