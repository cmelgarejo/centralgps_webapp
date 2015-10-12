defmodule CentralGPSWebApp.Client.Checkpoint.MonitorController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient

  def venues(conn, _) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {_, res} = api_get_json "/checkpoint/venues", session.auth_token, session.account_type
      p = res.body
        |> Map.update!(:rows, &(for x <- &1, do: (if x["active"], do: x))) #filter the active venues
        |> Map.update!(:rows, &(Enum.filter &1, fn(x)->!is_nil(x) end)) #filter out the nil values
      json conn, p
    end
  end

  def marks(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {_, res} = api_get_json "/checkpoint/marks", session.auth_token, session.account_type, params
      json conn, res.body
    end
  end

end
