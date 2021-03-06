defmodule CentralGPSWebApp.Client.AssetRoadmapController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  #POST    /api/v1/client/asset/:asset_id/roadmap/create
  #GET     /api/v1/client/asset/:asset_id/roadmap/:roadmap_id
  #PUT     /api/v1/client/asset/:asset_id/roadmap/:roadmap_id
  #DELETE  /api/v1/client/asset/:asset_id/roadmap/:roadmap_id
  #GET     /api/v1/client/asset/:asset_id/roadmap
  #GET     /api/v1/client/asset/roadmap


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
      render (conn |> assign(:parent_record, get_parent_record(session, params)) |> assign(:record, get_record(session, params))), "edit.html"
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
  defp api_method(asset_id, roadmap_id, action \\ "") when is_bitstring(action) do
    if (asset_id == "" && roadmap_id != "") do
      api_method_roadmap(roadmap_id, "", action)
    else
      if (asset_id != "" && roadmap_id == "") do
        api_method_asset(asset_id, "", action)
      else
        api_method_asset(asset_id, roadmap_id, action)
      end
    end
  end

  defp api_method_roadmap(roadmap_id, asset_id, action) when is_bitstring(action), do:
    String.replace("/client/roadmap/" <> roadmap_id <> "/asset/" <> asset_id <> "/" <> action, "//", "/")

  defp api_method_asset(asset_id, roadmap_id, action) when is_bitstring(action), do:
    String.replace("/client/asset/" <> asset_id <> "/roadmap/" <> roadmap_id <> "/" <> action, "//", "/")

  defp get_record(s, p) do
    p = objectify_map(p)
    {api_status, res} = api_get_json api_method(p.asset_id, p.roadmap_id), s.auth_token, s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg} ,
          %{asset_id: record.asset_id, roadmap_id: record.roadmap_id, emails: record.emails, phones: record.phones, alert: record.alert}
      end
    end
    record
  end

  defp save_record(s, p) do
    p = objectify_map(p)
    if (!Map.has_key?p, :__form__), do: p = Map.put p, :__form__, :edit
    if (!Map.has_key?p, :alert), do: p = Map.put( p, :alert, false), else: p = Map.update(p, :alert, false, &(&1 == "on"))
    if (String.to_atom(p.__form__) ==  :edit) do
      data = %{ emails: p.emails, phones: p.phones, alert: p.alert }
      {_, res} = api_put_json api_method(p.asset_id, p.roadmap_id), s.auth_token, s.account_type, data
    else
      data = %{ roadmap_id: p.roadmap_id, emails: p.emails, phones: p.phones, alert: p.alert }
      {_, res} = api_post_json api_method(p.asset_id, p.roadmap_id, "create"), s.auth_token, s.account_type, data
    end
    res.body
  end

  defp delete_record(s, p) do
    p = objectify_map p
    if(Map.has_key?(p, :asset_id) && Map.has_key?(p, :roadmap_id)) do
      {api_status, res} =
        api_delete_json api_method(p.asset_id, p.roadmap_id),
        s.auth_token, s.account_type
    else
      {api_status, res} = {:error, %{body: %{ status: false, msg: "no ids"}}}
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
      |> (Map.update :current,        1, &(parse_int(&1)))
      |> (Map.update :rowCount,      10, &(parse_int(&1)))
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
    {api_status, res} = api_get_json api_method(p.asset_id, p.roadmap_id), s.auth_token, s.account_type, qs
    rows = %{}
    if(api_status == :ok) do
      if res.body.status do
        rows = res.body.rows
          |> Enum.map(&(objectify_map &1))
          |> Enum.map &(%{asset_id: &1.asset_id, roadmap_id: &1.roadmap_id,
            asset_name: &1.asset_name , roadmap_name: &1.roadmap_name,
            emails: &1.emails, phones: &1.phones, alert: &1.alert })
      else
        res = Map.put res, :body, %{ status: false, msg: (if Map.has_key?(res, :activity), do: res.activity, else: res.body.msg) }
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    Map.merge((res.body |> Map.put :rows, rows), p)
  end

  defp api_parent_method(action) when is_bitstring(action), do: "/client/roadmap/" <> action
  defp get_parent_record(s, p) do
    p = objectify_map(p)
    {api_status, res} = api_get_json api_parent_method(p.roadmap_id), s.auth_token, s.account_type
    record = %{id: 0}
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg},
          %{ roadmap_id: record.id, roadmap: record.name, asset_id: nil, asset: nil }
      end
    end
    record
  end

end
