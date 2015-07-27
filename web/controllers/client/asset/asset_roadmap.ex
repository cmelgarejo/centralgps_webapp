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
      json conn, list_records(session, _params)
    end
  end

  def list_all(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, list_all_records(session, _params)
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
      render (conn |> assign :record, get_record(session, _params)), "edit.html"
    end
  end

  def save(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, save_record(session, _params)
    end
  end

  def delete(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, delete_record(session, _params)
    end
  end

  #private functions
  defp api_method(asset_id \\ "", roadmap_id \\ "", action \\ "") when is_bitstring(action),
    do: String.replace("/client/asset/" <> asset_id <> "/roadmap/" <> roadmap_id <> "/" <> action, "//", "/")

  defp get_record(_s, _p) do
    _p = objectify_map(_p)
    {api_status, res} = api_get_json api_method(_p.asset_id, _p.roadmap_id), _s.auth_token, _s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg} ,
          %{asset_id: record.asset_id, roadmap_id: record.roadmap_id, emails: record.emails, phones: record.phones, alarm: record.alarm}
      end
    end
    record
  end

  defp save_record(_s, _p) do
    _p = objectify_map(_p)
    if (!Map.has_key?_p, :__form__), do: _p = Map.put _p, :__form__, :edit
    if (String.to_atom(_p.__form__) ==  :edit) do
      data = %{ emails: _p.emails, phones: _p.phones, alarm: _p.alarm }
      {_, res} = api_put_json api_method(_p.action_id, _p.roadmap_id), _s.auth_token, _s.account_type, data
    else
      data = %{ roadmap_id: _p.roadmap_id, emails: _p.emails, phones: _p.phones, alarm: _p.alarm }
      {_, res} = api_post_json api_method(_p.asset_id, "", "create"), _s.auth_token, _s.account_type, data
    end
    res.body
  end

  defp delete_record(_s, _p) do
    _p = objectify_map _p
    if(Map.has_key?_p, :id) do
      {api_status, res} =
        api_delete_json api_method(_p.asset_id, _p.roadmap_id),
        _s.auth_token, _s.account_type
    else
      {api_status, res} = {:error, %{body: %{ status: false, msg: "no id"}}}
    end
    if(api_status == :ok) do
      if !res.body.status do
        msg = if Map.has_key?(res, :reason), do: res.reason, else: res.body.msg
        res = Map.put res, :body, %{ status: false, msg: msg }
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    res.body
  end

  defp list_records(_s, _p) do
    _p = objectify_map(_p)
      |> (Map.update :current, 1, &(parse_int(&1)))
      |> (Map.update :rowCount, 10, &(parse_int(&1)))
      |> (Map.update :searchColumn, nil, fn(v)->(v) end)
      |> (Map.update :searchPhrase, nil, fn(v)->(v) end)
      |> (Map.put :sort_column, nil)
      |> (Map.put :sort_order, nil)
    if Map.has_key?_p, :sort do
      _p = Map.put(_p, :sort_column, Map.keys(_p.sort) |> hd)
        |> Map.put(:sort_order, Map.values(_p.sort) |> hd)
    end
    qs = %{offset: (_p.current - 1) * _p.rowCount, limit: _p.rowCount,
      search_column: _p.searchColumn, search_phrase: _p.searchPhrase,
      sort_column: _p.sort_column, sort_order: _p.sort_order}
    {api_status, res} = api_get_json api_method(_p.asset_id), _s.auth_token, _s.account_type, qs
    rows = %{}
    if(api_status == :ok) do
      if res.body.status do
        rows = res.body.rows
          |> Enum.map(&(objectify_map &1))
          #|> Enum.map &(%{asset_id: &1.asset_id, description: &1.description })
      else
        msg = if Map.has_key?(res, :reason), do: res.reason, else: res.body.msg
        res = Map.put res, :body, %{ status: false, msg: msg }
      end
    end
    Map.merge((res.body |> Map.put :rows, rows), _p)
  end

  defp list_all_records(_s, _p) do
    _p = objectify_map(_p)
      |> (Map.update :current, 1, &(parse_int(&1)))
      |> (Map.update :rowCount, 10, &(parse_int(&1)))
      |> (Map.update :searchColumn, nil, fn(v)->(v) end)
      |> (Map.update :searchPhrase, nil, fn(v)->(v) end)
      |> (Map.put :sort_column, nil)
      |> (Map.put :sort_order, nil)
    if Map.has_key?_p, :sort do
      _p = Map.put(_p, :sort_column, Map.keys(_p.sort) |> hd)
        |> Map.put(:sort_order, Map.values(_p.sort) |> hd)
    end
    qs = %{offset: (_p.current - 1) * _p.rowCount, limit: _p.rowCount,
      search_column: _p.searchColumn, search_phrase: _p.searchPhrase,
      sort_column: _p.sort_column, sort_order: _p.sort_order}
    {api_status, res} = api_get_json api_method, _s.auth_token, _s.account_type, qs
    rows = %{}
    if(api_status == :ok) do
      if res.body.status do
        rows = res.body.rows
          |> Enum.map(&(objectify_map &1))
          #|> Enum.map &(%{id: &1.id, description: &1.description })
      else
        res = Map.put res, :body, %{ status: false, msg: res.reason }
      end
    end
    Map.merge((res.body |> Map.put :rows, rows), _p)
  end

end
