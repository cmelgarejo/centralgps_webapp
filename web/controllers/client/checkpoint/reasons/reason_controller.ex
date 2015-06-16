defmodule CentralGPSWebApp.Client.Checkpoint.ReasonController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities
  plug :action

  # POST    /checkpoint/reasons/create
  # GET     /checkpoint/reasons/:reason_id
  # PUT     /checkpoint/reasons/:reason_id
  # DELETE  /checkpoint/reasons/:reason_id
  # GET     /checkpoint/reasons
  # GET     /checkpoint/reasons/json

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
      {api_status, res} = api_get_json "/checkpoint/reasons", session.auth_token, session.account_type, qs
      {result, rows} = {%{}, %{}}
      if(api_status == :ok) do
        if res.body.status do
          rows = res.body.rows
            |> Enum.map(&(objectify_map &1))
            |> Enum.map &(%{id: &1.id, description: &1.description })
          #result = res.body |> Map.put :rows, rows
          #result = Map.merge _params, (res.body |> Map.put :rows, rows)
        else

        end
        result = Map.merge (res.body |> Map.put :rows, rows), _params
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
      {api_status, res} = api_get_json "/checkpoint/reasons/" <> _params.id, session.auth_token, session.account_type
      record = nil
      if(api_status == :ok) do
        if res.body.status do
          record = objectify_map(res.body.res)
          record = %{id: record.id, configuration_id: record.configuration_id, description: record.description}
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
      _params = objectify_map(_params)
      if(Map.has_key?_params, :id) do
        data = %{reason_id: _params.id, configuration_id: _params.configuration_id, description: _params.description}
        {api_status, res} = api_put_json "/checkpoint/reasons/" <> data.reason_id,
          session.auth_token, session.account_type, data
      else
        data = %{ configuration_id: session.client_id, description: _params.description }
        {api_status, res} = api_post_json "/checkpoint/reasons/create",
          session.auth_token, session.account_type, data
      end
      #if(api_status == :ok) do
      #  if res.body.status do
      #  else
      #    #do something if status = false?
      #  end
      #end
      json conn, res.body
    end
  end

  def delete(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      _params = objectify_map(_params)
      if(Map.has_key?_params, :id) do
        {api_status, res} =
          api_delete_json "/checkpoint/reasons/" <> _params.id,
          session.auth_token, session.account_type
      else
        {api_status, res} = {:error, %{body: %{ status: false, msg: "MEGA ERROR"}}}
      end
      if(api_status == :ok) do
        if res.body.status do
        else
          #do something if status = false?
        end
      end
      json conn, res.body
    end
  end
end
