defmodule CentralGPSWebApp.Client.Checkpoint.ActivityController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /checkpoint/activities/create
  # GET     /checkpoint/activities/:activity_id
  # PUT     /checkpoint/activities/:activity_id
  # DELETE  /checkpoint/activities/:activity_id
  # GET     /checkpoint/activities
  # GET     /checkpoint/activities/json

  def index(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render (conn |> assign(:parent_record, get_parent_record(session, params))), "index.html"
    end
  end

  def list(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, list_records(session, params)
    end
  end

  def new(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render (conn |> assign(:parent_record, get_parent_record(session, params))), "new.html"
    end
  end

  def edit(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render (conn |> assign(:record, get_record(session, params)) |> assign(:parent_record, get_parent_record(session, params))), "edit.html"
    end
  end

  def save(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, save_record(session, params)
    end
  end

  def delete(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, delete_record(session, params)
    end
  end

  #private functions
  defp api_method(form_id \\ "", activity_id \\ "") when is_bitstring(form_id) and is_bitstring(activity_id), do: "/checkpoint/activity/" <> form_id <> "/" <> activity_id

  defp get_record(s, p) do
    p = objectify_map(p)
    {api_status, res} = api_get_json api_method(p.form_id, p.id), s.auth_token, s.account_type
    record = nil
    if(api_status == :ok) do
      if res.body.status do
        if(Map.has_key?res.body, :res) do
          record = objectify_map res.body.res
          record = %{id: record.id, description: record.description}
        end
        record = Map.merge %{status: res.body.status, msg: res.body.msg} , record
      end
    end
    record
  end

  defp save_record(s, p) do
    p = objectify_map(p)
    if (!Map.has_key?p, :__form__), do: p = Map.put p, :__form__, :edit
    res = %{body: nil}
    if (String.to_atom(p.__form__) ==  :edit) && res do
      data = %{activity_id: p.id, configuration_id: s.configuration_id, description: p.description}
      {_, res} = api_put_json api_method(p.id), s.auth_token, s.account_type, data
    else
      data = %{ configuration_id: s.configuration_id, form_id: p.form_id, description: p.description }
      {_, res} = api_post_json api_method("create"), s.auth_token, s.account_type, data
    end
    res.body
  end

  defp delete_record(s, p) do
    p = objectify_map p
    {api_status, res} = {false, nil}
    if (Map.has_key?p, :id) && !api_status && res do
      {api_status, res} = api_delete_json(api_method(p.id), s.auth_token, s.account_type)
    else
      {api_status, res} = {:error, %{body: %{ status: false, msg: "no id"}}}
    end
    if (api_status == :ok) do
      if !res.body.status, do: res = Map.put res, :body, %{ status: false, msg: res.body.msg }
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    res
  end

  defp list_records(s, p) do
    p = objectify_map(p)
      |> (Map.update :form_id, 0, &(parse_int(&1)))
      |> (Map.update :current, 1, &(parse_int(&1)))
      |> (Map.update :rowCount, 10, &(parse_int(&1)))
      |> (Map.update :searchColumn, nil, fn(v)->(v) end)
      |> (Map.update :searchPhrase, nil, fn(v)->(v) end)
      |> (Map.put :sort_column, nil)
      |> (Map.put :sort_order, nil)
    if Map.has_key?p, :sort do
      p = Map.put(p, :sort_column, Map.keys(p.sort) |> hd)
        |> Map.put(:sort_order, Map.values(p.sort) |> hd)
    end
    qs = %{offset: (p.current - 1) * p.rowCount, limit: p.rowCount,
      search_column: p.searchColumn, search_phrase: p.searchPhrase,
      sort_column: p.sort_column, sort_order: p.sort_order, form_id: p.form_id}
    {api_status, res} = api_get_json api_method, s.auth_token, s.account_type, qs
    rows = %{}
    if(api_status == :ok) do
      if res.body.status do
        rows = res.body.rows |> Enum.map(&(objectify_map &1))
      else
        res = Map.put res, :body, %{ status: false, msg: (if Map.has_key?(res, :activity), do: res.activity, else: res.body.msg) }
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    Map.merge((res.body |> Map.put(:rows, rows)), p)
  end

  defp api_parent_method(action) when is_bitstring(action), do: "/checkpoint/form/" <> action
  defp get_parent_record(s, p) do
    p = objectify_map(p)
    {api_status, res} = api_get_json api_parent_method(p.form_id), s.auth_token, s.account_type
    record = %{id: 0}
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg},
          %{ id: record.id, form_id: record.id, description: record.description }
      end
    end
    record
  end
end
