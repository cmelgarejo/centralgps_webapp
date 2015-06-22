defmodule CentralGPSWebApp.Client.Checkpoint.MonitorController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient


  def venues(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {_, res} = api_get_json "/checkpoint/venues", session.auth_token, session.account_type
      json conn, res.body
    end
  end

#TODO: hacer que los marks tambien traigan el lat/lon del venue que hacen check, para poder
#marcar donde se debe, en el venue, no en el, o lo hago en el JS nada mas directo? hmm....
  def marks(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {_, res} = api_get_json "/checkpoint/marks", session.auth_token, session.account_type, _params
      json conn, res.body
    end
  end

end
