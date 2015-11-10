defmodule CentralGPSWebApp.Client.AssetController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /client/asset/create
  # GET     /client/asset/:asset_id
  # PUT     /client/asset/:asset_id
  # DELETE  /client/asset/:asset_id
  # GET     /client/asset
  # GET     /client/asset/json

  def index(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render (conn |> assign :parent_record, get_parent_record(session, params)), "index.html"
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
      render (conn |> assign :parent_record, get_parent_record(session, params)), "new.html"
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
  defp api_method(roadmap_id, asset_id \\ "", form \\ "") when is_bitstring(form),
    do: String.replace("/client/roadmap/" <> roadmap_id <> "/asset/" <> asset_id <> "/" <> form, "//", "/")

  defp get_record(s, p) do
    p = objectify_map(p)
    {api_status, res} = api_get_json api_method(p.roadmap_id, p.asset_id), s.auth_token, s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg} , record
          #%{asset_id: record.asset_id, roadmap_id: record.roadmap_id, emails: record.emails, phones: record.phones, alarm: record.alarm}
      end
    end
    record
  end

  defp save_record(s, p) do
    p = objectify_map(p)
    if (!Map.has_key?p, :__form__), do: p = Map.put p, :__form__, :edit
    if (String.to_atom(p.__form__) ==  :edit) do
      data = %{ emails: p.emails, phones: p.phones, alarm: p.alarm }
      {_, res} = api_put_json api_method(p.roadmap_id, p.asset_id), s.auth_token, s.account_type, data
    else
      data = %{ roadmap_id: p.roadmap_id, emails: p.emails, phones: p.phones, alarm: p.alarm }
      {_, res} = api_post_json api_method(p.roadmap_id, p.asset_id, "create"), s.auth_token, s.account_type, data
    end
    res.body
  end

  defp delete_record(s, p) do
    p = objectify_map p
    if(Map.has_key?p, :id) do
      {api_status, res} =
        api_delete_json api_method(p.asset_id, p.roadmap_id),
        s.auth_token, s.account_type
    else
      {api_status, res} = {:error, %{body: %{ status: false, msg: "no id"}}}
    end
    if(api_status == :ok) do
      if !res.body.status do
        msg = if Map.has_key?(res, :activity), do: res.activity, else: res.body.msg
        res = Map.put res, :body, %{ status: false, msg: msg }
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    res.body
  end

  defp list_records(s, p) do
    p = objectify_map(p)
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
      sort_column: p.sort_column, sort_order: p.sort_order}
    {api_status, res} = api_get_json api_method(p.roadmap_id), s.auth_token, s.account_type, qs
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
    Map.merge((res.body |> Map.put :rows, rows), p)
  end

  defp api_parent_method(roadmap_id) when is_bitstring(roadmap_id), do: "/checkpoint/roadmap/" <> roadmap_id
  defp get_parent_record(s, p) do
    p = objectify_map(p)
    {api_status, res} = api_get_json api_parent_method(p.form_id), s.auth_token, s.account_type
    record = %{id: 0}
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg},
          %{ id: record.id, roadmap_id: record.id, name: record.name, description: record.description }
      end
    end
    record
  end
end
