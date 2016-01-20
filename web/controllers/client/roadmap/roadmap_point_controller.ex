defmodule CentralGPSWebApp.Client.RoadmapPointController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /api/v1/client/roadmap/:roadmap_id/point/create
  # GET     /api/v1/client/roadmap/:roadmap_id/point/:roadmap_point_id
  # PUT     /api/v1/client/roadmap/:roadmap_id/point/:roadmap_point_id
  # DELETE  /api/v1/client/roadmap/:roadmap_id/point/:roadmap_point_id
  # GET     /api/v1/client/roadmap/:roadmap_id/point

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
      render (conn |> assign :record, get_record(session, params)), "edit.html"
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

  def order(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, point_order(session, params)
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
  defp api_method(roadmap_id, action \\ "") do
    if !is_bitstring(roadmap_id), do: roadmap_id = Integer.to_string(roadmap_id)
    "/client/roadmap/" <> roadmap_id <> "/point/" <> action
  end

  defp get_record(s, p) do
    p = objectify_map(p)
    {api_status, res} = api_get_json api_method(p.roadmap_id, p.id), s.auth_token, s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map res.body.res
      Map.merge record, %{roadmap_id: p.roadmap_id}
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg}, record
      end
    end
    record
  end

  defp save_record(s, p) do
    try do
      p = objectify_map(p)
      if (!Map.has_key?p, :__form__), do: p = Map.put p, :__form__, :edit
      if (!Map.has_key?p, :mean_arrival_time), do: p = Map.put p, :mean_arrival_time, nil
      if (!Map.has_key?p, :mean_leave_time),   do: p = Map.put p, :mean_leave_time, nil
      if (String.length(p.mean_arrival_time) == 5), do: p = Map.update!(p, :mean_arrival_time, &((&1 <> ":00"))) #quick and dirty patch, TODO: find a better way to check TIME strings
      if (String.length(p.mean_leave_time) == 5), do: p = Map.update!(p, :mean_leave_time, &((&1 <> ":00"))) #quick and dirty patch, TODO: find a better way to check TIME strings
      if (!Map.has_key?p, :rpvf_id), do: p = Map.put p, :rpvf_id, nil
      if (!Map.has_key?p, :venue_id), do: p = Map.put p, :venue_id, nil
      if (!Map.has_key?p, :form_id), do: p = Map.put p, :form_id, nil
      if (!Map.has_key?p, :active), do: p = Map.put( p, :active, false), else: p = Map.update(p, :active, false, &(&1 == "on"))
      if (!Map.has_key?p, :xtra_info), do: p = Map.put p, :xtra_info, nil
      if (String.to_atom(p.__form__) ==  :edit) do
        data = %{ id: p.id, roadmap_id: p.roadmap_id, name: p.name, description: p.description,
          notes: p.notes, lat: p.lat, lon: p.lon, point_order: p.point_order,
          mean_arrival_time: p.mean_arrival_time, mean_leave_time: p.mean_leave_time,
          detection_radius: p.detection_radius, active: p.active, xtra_info: p.xtra_info,
          rpvf_id: p.rpvf_id, venue_id: p.venue_id, form_id: p.form_id }
        {_, res} = api_put_json api_method(data.roadmap_id, data.id), s.auth_token, s.account_type, data
      else
        data = %{ roadmap_id: p.roadmap_id, name: p.name, description: p.description,
          notes: p.notes, lat: p.lat, lon: p.lon, point_order: p.point_order,
          mean_arrival_time: p.mean_arrival_time, mean_leave_time: p.mean_leave_time,
          detection_radius: p.detection_radius, active: p.active, xtra_info: p.xtra_info,
          venue_id: p.venue_id, form_id: p.form_id }
        {_, res} = api_post_json api_method(data.roadmap_id, "create"), s.auth_token, s.account_type, data
      end
      res.body
    rescue
      e in _ -> %{ status: false, msg: error_logger(e, __ENV__) }
    end
  end

  defp point_order(s, p) do
    p = objectify_map p
    if(Map.has_key?p, :id) do
      {api_status, res} =
        api_put_json api_method(p.roadmap_id, p.id <> "/" <> p.order),
        s.auth_token, s.account_type, %{}
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

  defp delete_record(s, p) do
    p = objectify_map p
    if(Map.has_key?p, :id) do
      {api_status, res} =
        api_delete_json api_method(p.roadmap_id, p.id),
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
      |> (Map.update :id, 0, &(parse_int(&1)))
      |> (Map.update :roadmap_id, 0, &(parse_int(&1)))
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
      sort_column: p.sort_column, sort_order: p.sort_order, roadmap_id: p.roadmap_id}
    {api_status, res} = api_get_json api_method(p.roadmap_id), s.auth_token, s.account_type, qs
    rows = %{}
    if(api_status == :ok) do
      if res.body.status do
        rows = res.body.rows |> Enum.map(&(objectify_map &1)) #|> Enum.map &(%{id: &1.id, description: &1.description })
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
          %{ id: record.id, name: record.name, description: record.description,
          notes: record.notes, one_time_date: record.one_time_date,
          interval: record.interval, days_of_week: record.days_of_week,
          months_of_year: record.months_of_year, days_of_month: record.days_of_month,
          recurs_every: record.recurs_every, start_time: record.start_time, end_time: record.end_time,
          public: record.public, active: record.active , last_point_order: record.last_point_order + 1 }
      end
    end
    record
  end
end
