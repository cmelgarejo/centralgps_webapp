defmodule CentralGPSWebApp.Client.Checkpoint.ActionController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities
  plug :action

  # POST    /api/v1/checkpoint/actions/create
  # GET     /api/v1/checkpoint/actions/:action_id
  # PUT     /api/v1/checkpoint/actions/:action_id
  # DELETE  /api/v1/checkpoint/actions/:action_id
  # GET     /api/v1/checkpoint/actions
  # GET     /api/v1/checkpoint/actions/json

  def index(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render conn, "index.html"
    end
  end

  def json_list(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      {api_status, res} = api_get_json "/checkpoint/actions", session.auth_token, "C"
      result = %{}
      if(api_status == :ok) do
        if res.body.status do
          result = res.body
          list = res.body.list
            |> Enum.map(&(objectify_map &1))
            |> Enum.map &(%{id: &1.id, description: &1.description })
          IO.puts "RES.BODY: #{inspect res.body}"
          #TODO: make this standard on the fn_api_* from database itself!
          result = res.body |> Map.put(:rows, list) |> Map.put(:current, 1)
            |> Map.put(:row_count, 2) |> Map.put(:total, 2)
          IO.puts "RESULT: #{inspect result}"
        else

        end
      end
      json conn, result
    end
  end

  def new(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, %{ new: ""}
    end
  end

  def show(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, %{ show: ""}
    end
  end

  def edit(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, %{ edit: ""}
    end
  end

  def delete(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, %{ delete: ""}
    end
  end
end
