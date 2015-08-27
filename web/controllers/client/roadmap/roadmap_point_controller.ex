defmodule CentralGPSWebApp.Client.RoadmapPointController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /api/v1/client/roadmaps/:roadmap_id/points/create
  # GET     /api/v1/client/roadmaps/:roadmap_id/points/:roadmap_point_id
  # PUT     /api/v1/client/roadmaps/:roadmap_id/points/:roadmap_point_id
  # DELETE  /api/v1/client/roadmaps/:roadmap_id/points/:roadmap_point_id
  # GET     /api/v1/client/roadmaps/:roadmap_id/points

  def index(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render (conn |> assign :parent_record, get_parent_record(session, _params)), "index.html"
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

  def new(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render (conn |> assign :parent_record, get_parent_record(session, _params)), "new.html"
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
  defp api_method(roadmap_id, action \\ "") do
    if !is_bitstring(roadmap_id), do: roadmap_id = Integer.to_string(roadmap_id)
    "/client/roadmaps/" <> roadmap_id <> "/points/" <> action
  end

  defp get_record(_s, _p) do
    _p = objectify_map(_p)
    IO.puts "_p: #{inspect _p}"
    {api_status, res} = api_get_json api_method(_p.roadmap_id, _p.id), _s.auth_token, _s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map res.body.res
      Map.merge record, %{roadmap_id: _p.roadmap_id}
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg}, record
      end
    end
    IO.puts "RECORD: #{inspect record}"
    record
  end

  defp save_record(_s, _p) do
    try do
      _p = objectify_map(_p)
      if (!Map.has_key?_p, :__form__), do: _p = Map.put _p, :__form__, :edit
      if (!Map.has_key?_p, :mean_arrival_time), do: _p = Map.put _p, :mean_arrival_time, nil
      if (!Map.has_key?_p, :mean_leave_time), do: _p = Map.put _p, :mean_leave_time, nil
      if (!Map.has_key?_p, :active), do: _p = Map.put( _p, :active, false), else: _p = Map.update(_p, :active, false, &(&1 == "on"))
      if (!Map.has_key?_p, :xtra_info), do: _p = Map.put _p, :xtra_info, nil
      if (String.to_atom(_p.__form__) ==  :edit) do
        data = %{ id: _p.id, roadmap_id: _p.roadmap_id, name: _p.name, description: _p.description,
          lat: _p.lat, lon: _p.lon, point_order: _p.point_order,
          mean_arrival_time: _p.mean_arrival_time, mean_leave_time: _p.mean_leave_time,
          detection_radius: _p.detection_radius, active: _p.active, xtra_info: _p.xtra_info}
        {_, res} = api_put_json api_method(data.roadmap_id, data.id), _s.auth_token, _s.account_type, data
      else
        data = %{ roadmap_id: _p.roadmap_id, name: _p.name, description: _p.description,
          lat: _p.lat, lon: _p.lon, point_order: _p.point_order,
          mean_arrival_time: _p.mean_arrival_time, mean_leave_time: _p.mean_leave_time,
          detection_radius: _p.detection_radius, active: _p.active, xtra_info: _p.xtra_info}
        {_, res} = api_post_json api_method(data.roadmap_id, "create"), _s.auth_token, _s.account_type, data
      end
      res.body
    rescue
      e in _ -> %{ status: false, msg: error_logger(e, __ENV__) }
    end
  end

  defp delete_record(_s, _p) do
    _p = objectify_map _p
    if(Map.has_key?_p, :id) do
      {api_status, res} =
        api_delete_json api_method(_p.roadmap_id, _p.id),
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
      |> (Map.update :id, 0, &(parse_int(&1)))
      |> (Map.update :roadmap_id, 0, &(parse_int(&1)))
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
      sort_column: _p.sort_column, sort_order: _p.sort_order, roadmap_id: _p.roadmap_id}
    {api_status, res} = api_get_json api_method(_p.roadmap_id), _s.auth_token, _s.account_type, qs
    rows = %{}
    if(api_status == :ok) do
      if res.body.status do
        rows = res.body.rows
          |> Enum.map(&(objectify_map &1))
          #|> Enum.map &(%{id: &1.id, description: &1.description })
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    Map.merge((res.body |> Map.put :rows, rows), _p)
  end

  defp api_parent_method(action) when is_bitstring(action), do: "/client/roadmaps/" <> action
  defp get_parent_record(_s, _p) do
    _p = objectify_map(_p)
    IO.puts "_p: #{inspect _p}"
    {api_status, res} = api_get_json api_parent_method(_p.roadmap_id), _s.auth_token, _s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg},
          %{ id: record.id, name: record.name, description: record.description,
          days_of_week: record.days_of_week, repetition: record.repetition,
          one_time_date: record.one_time_date, start_time: record.start_time, end_time: record.end_time,
          public: record.public, active: record.active }
      end
    end
    record
  end
end
