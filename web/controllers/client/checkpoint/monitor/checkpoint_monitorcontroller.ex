defmodule CentralGPSWebApp.Client.Checkpoint.MonitorController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  def venues(conn, _) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {api_status, res} = api_get_json "/checkpoint/venue", session.auth_token, session.account_type
      if(api_status == :ok) do
        if res.body.status do
          p = res.body
            |> Map.update!(:rows, &(for x <- &1, do: (if x["active"], do: x))) #filter the active venues
            |> Map.update!(:rows, &(Enum.filter &1, fn(x)->!is_nil(x) end)) #filter out the nil values
          rows = p.rows
        else
          res = Map.put res, :body, %{ status: false, msg: (if Map.has_key?(res, :activity), do: res.activity, else: res.body.msg) }
        end
      else
        res = Map.put res, :body, %{ status: false, msg: res.reason }
      end
      json conn, (res.body |> Map.put :rows, rows)
    end
  end

  def marks(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {api_status, res} = api_get_json "/checkpoint/mark", session.auth_token, session.account_type, params
      if(api_status == :ok) do
        if res.body.status do
          rows = res.body.rows |> Enum.map(&(objectify_map &1))
        else
          res = Map.put res, :body, %{ status: false, msg: (if Map.has_key?(res, :activity), do: res.activity, else: res.body.msg) }
        end
      else
        res = Map.put res, :body, %{ status: false, msg: res.reason }
      end
      json conn, (res.body |> Map.put :rows, rows)
    end
  end

end
