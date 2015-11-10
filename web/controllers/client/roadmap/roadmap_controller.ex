defmodule CentralGPSWebApp.Client.RoadmapController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /api/v1/client/roadmap/create
  # GET     /api/v1/client/roadmap/:roadmap_id
  # PUT     /api/v1/client/roadmap/:roadmap_id
  # DELETE  /api/v1/client/roadmap/:roadmap_id
  # GET     /api/v1/client/roadmap

  def index(conn, _) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render conn, "index.html"
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

  def new(conn, _) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render conn, "new.html"
    end
  end

  def view(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render (conn |> assign :record, get_record(session, params)), "view.html"
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

  def delete(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, delete_record(session, params)
    end
  end

  #private functions
  defp api_method(action \\ "") when is_bitstring(action), do: "/client/roadmap/" <> action

  defp get_record(s, p) do
    p = objectify_map(p)
    {api_status, res} = api_get_json api_method(p.id), s.auth_token, s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg} ,
          %{ id: record.id, roadmap_id: record.id, name: record.name, description: record.description,
          notes: record.notes, one_time_date: record.one_time_date,
          interval: record.interval, days_of_week: record.days_of_week,
          months_of_year: record.months_of_year, days_of_month: record.days_of_month,
          recurs_every: record.recurs_every, start_time: record.start_time, end_time: record.end_time,
          public: record.public, active: record.active }
      end
    end
    record
  end

  defp save_record(s, p) do
    try do
      p = objectify_map(p)
      if (!Map.has_key?p, :__form__), do: p = Map.put p, :__form__, :edit
      if (!Map.has_key?p, :one_time_date), do: p = Map.put p, :one_time_date, nil
      if (!Map.has_key?p, :public), do: p = Map.put( p, :public, false), else: p = Map.update(p, :public, false, &(&1 == "on"))
      if (!Map.has_key?p, :active), do: p = Map.put( p, :active, false), else: p = Map.update(p, :active, false, &(&1 == "on"))
      if (!Map.has_key?p, :xtra_info), do: p = Map.put p, :xtra_info, nil
      if (!Map.has_key?p, :days_of_week) do
        p = Map.put p, :days_of_week, nil
      else
        p = Map.put p, :days_of_week, Enum.map(p.days_of_week, &(parse_int(&1)))
      end
      if (!Map.has_key?p, :months_of_year) do
        p = Map.put p, :months_of_year, nil
      else
        p = Map.put p, :months_of_year, Enum.map(p.months_of_year, &(parse_int(&1)))
      end
      if (!Map.has_key?p, :days_of_month) do
        p = Map.put p, :days_of_month, nil
      else
        p = Map.put p, :days_of_month, Enum.map(p.days_of_month, &(parse_int(&1)))
      end
      if (String.to_atom(p.__form__) ==  :edit) do
        data = %{ roadmap_id: p.id, name: p.name, description: p.description,
          notes: p.notes, one_time_date: p.one_time_date,
          interval: p.interval, days_of_week: p.days_of_week,
          months_of_year: p.months_of_year, days_of_month: p.days_of_month,
          recurs_every: p.recurs_every, start_time: p.start_time, end_time: p.end_time,
          public: p.public, active: p.active, xtra_info: p.xtra_info}
        {_, res} = api_put_json api_method(data.roadmap_id), s.auth_token, s.account_type, data
      else
        data = %{ name: p.name, description: p.description,
          notes: p.notes, one_time_date: p.one_time_date,
          interval: p.interval, days_of_week: p.days_of_week,
          months_of_year: p.months_of_year, days_of_month: p.days_of_month,
          recurs_every: p.recurs_every, start_time: p.start_time, end_time: p.end_time,
          public: p.public, active: p.active, xtra_info: p.xtra_info}
        {_, res} = api_post_json api_method("create"), s.auth_token, s.account_type, data
      end
      res.body
    rescue
      e in _ -> %{ status: false, msg: error_logger(e, __ENV__) }
    end
  end

  defp delete_record(s, p) do
    p = objectify_map p
    if(Map.has_key?p, :id) do
      {api_status, res} =
        api_delete_json api_method(p.id),
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
    {api_status, res} = api_get_json api_method, s.auth_token, s.account_type, qs
    rows = %{}
    if(api_status == :ok) do
      if res.body.status do
        rows = res.body.rows |> Enum.map(&(objectify_map &1))
          #|> Enum.map &(%{id: &1.id, name:&1.name, description: &1.des cription,
          #  days_of_week: &1.days_of_week, repetition: &1.repetition,
          #  one_time_date: &1.one_time_date, start_time: &1.start_time, end_time: &1.end_time,
          #  xtra_info: &1.xtra_info,
          #  activated_at: &1.activated_at
          #  })
      else
        res = Map.put res, :body, %{ status: false, msg: (if Map.has_key?(res, :activity), do: res.activity, else: res.body.msg) }
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    Map.merge((res.body |> Map.put :rows, rows), p)
  end

end
