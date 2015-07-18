defmodule CentralGPSWebApp.Client.RoadmapController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /api/v1/client/roadmaps/create
  # GET     /api/v1/client/roadmaps/:roadmap_id
  # PUT     /api/v1/client/roadmaps/:roadmap_id
  # DELETE  /api/v1/client/roadmaps/:roadmap_id
  # GET     /api/v1/client/roadmaps

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
  defp api_method(action \\ "") when is_bitstring(action), do: "/client/roadmaps/" <> action

  defp get_record(_s, _p) do
    _p = objectify_map(_p)
    {api_status, res} = api_get_json api_method(_p.id), _s.auth_token, _s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg} ,
          %{id: record.id, configuration_id: record.configuration_id, description: record.description}
      end
    end
    record
  end

  defp save_record(_s, _p) do
    _p = objectify_map(_p)
    if (!Map.has_key?_p, :__form__), do: _p = Map.put _p, :__form__, :edit
    if (String.to_atom(_p.__form__) ==  :edit) do
      data = %{roadmap_id: _p.id, configuration_id: _s.client_id, description: _p.description}
      {_, res} = api_put_json api_method(data.roadmap_id), _s.auth_token, _s.account_type, data
    else
      data = %{ configuration_id: _s.client_id, description: _p.description }
      {_, res} = api_post_json api_method("create"), _s.auth_token, _s.account_type, data
    end
    res.body
  end

  defp delete_record(_s, _p) do
    _p = objectify_map _p
    if(Map.has_key?_p, :id) do
      {api_status, res} =
        api_delete_json api_method(_p.id),
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
    {api_status, res} = api_get_json api_method, _s.auth_token, _s.account_type, qs
    rows = %{}
    if(api_status == :ok) do
      if res.body.status do
        rows = res.body.rows
          |> Enum.map(&(objectify_map &1))
          #|> Enum.map &(%{id: &1.id, name:&1.name, description: &1.description,
          #  days_of_week: &1.days_of_week, repetition: &1.repetition,
          #  one_time_date: &1.one_time_date, start_time: &1.start_time, end_time: &1.end_time,
          #  xtra_info: &1.xtra_info,
          #  activated_at: &1.activated_at
          #  })
      else
        res = Map.put res, :body, %{ status: false, msg: res.reason }
      end
    end
    Map.merge((res.body |> Map.put :rows, rows), _p)
  end

end
