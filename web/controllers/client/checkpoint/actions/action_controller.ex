defmodule CentralGPSWebApp.Client.Checkpoint.ActionController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities
  plug :action

  # POST    /checkpoint/actions/create
  # GET     /checkpoint/actions/:action_id
  # PUT     /checkpoint/actions/:action_id
  # DELETE  /checkpoint/actions/:action_id
  # GET     /checkpoint/actions
  # GET     /checkpoint/actions/json

  def index(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render conn, "index.html"
    end
  end

  def list(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      _params = objectify_map(_params)
        |> (Map.update :current, 0, fn(v)->(if !is_integer(v), do: elem(Integer.parse(v), 0), else: v) end)
        |> (Map.update :rowCount, 10, fn(v)->(if !is_integer(v), do: elem(Integer.parse(v), 0), else: v) end)
      qs = %{offset: (_params.current - 1) * _params.rowCount, limit: _params.rowCount,
      search_column: _params.searchColumn, search_phrase: _params.searchPhrase }
      {api_status, res} = api_get_json "/checkpoint/actions", session.auth_token, "C", qs
      result = %{}
      if(api_status == :ok) do
        if res.body.status do
          rows = res.body.rows
            |> Enum.map(&(objectify_map &1))
            |> Enum.map &(%{id: &1.id, description: &1.description })
          #TODO: make this standard on the fn_api_* from database itself!
          result = Map.merge _params, (res.body |> Map.put :rows, rows)
        else
          #do something if status = false?
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
      render conn, "new.html"
    end
  end

  def edit(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      _params = objectify_map(_params)
      {api_status, res} = api_get_json "/checkpoint/actions/" <> _params.action_id, session.auth_token, "C"
      record = nil
      IO.puts "EDIT.ACTION:#{inspect objectify_map(res.body.res)}"
      if(api_status == :ok) do
        if res.body.status do
          record = objectify_map(res.body.res)
          record = %{id: record.id, description: record.description}
          #TODO: make this standard on the fn_api_* from database itself!
        else
          #do something if status = false?
        end
      end
      render (conn |> assign :record, record), "edit.html"
    end
  end

  def save(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, %{status: false, msg: "NOT SAVED."}
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
