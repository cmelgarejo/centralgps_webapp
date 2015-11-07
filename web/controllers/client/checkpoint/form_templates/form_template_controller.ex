defmodule CentralGPSWebApp.Client.Checkpoint.FormTemplateController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /checkpoint/form_template/create
  # GET     /checkpoint/form_template/:form_id
  # PUT     /checkpoint/form_template/:form_id
  # DELETE  /checkpoint/form_template/:form_id
  # GET     /checkpoint/form_template
  # GET     /checkpoint/form_template/json

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
      render conn |> assign(:record, get_record(session, params)) |> assign(:parent_record, get_parent_record(session, params)), "edit.html"
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
  defp api_method(form) when is_bitstring(form), do: "/checkpoint/form_template/" <> form

  defp get_record(s, p) do
    p = objectify_map(p)
    {api_status, res} = api_get_json api_method(p.id), s.auth_token, s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg} ,
          %{id: record.id, form_id: record.form_id, activity_id: record.activity_id,
            item_id: record.item_id, measure_unit_id: record.measure_unit_id }
      end
    end
    record
  end

  defp save_record(s, p) do
    p = objectify_map(p)
    if (!Map.has_key?p, :__form__), do: p = Map.put p, :__form__, :edit
    if (String.to_atom(p.__form__) ==  :edit) do
      data = %{ id: p.id, form_id: p.form_id, activity_id: p.activity_id,
        item_id: p.item_id, measure_unit_id: p.measure_unit_id }
      {_, res} = api_put_json api_method(data.id), s.auth_token, s.account_type, data
    else
      data = %{ form_id: p.form_id, activity_id: p.activity_id,
        item_id: p.item_id, measure_unit_id: p.measure_unit_id }
      {_, res} = api_post_json api_method("create"), s.auth_token, s.account_type, data
    end
    res.body
  end

  defp delete_record(s, p) do
    p = objectify_map p
    if(Map.has_key?p, :id) do
      {api_status, res} =
        api_delete_json api_method(p.id <> "/true"),
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
    {api_status, res} = api_get_json api_method(p.form_id <> "/" <> p.activity_id), s.auth_token, s.account_type, qs
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

  defp api_form_parent_method(form)   when is_bitstring(form), do: "/checkpoint/form/" <> form
  defp api_form_activity_method(form_id, activity_id) when is_bitstring(form_id) and is_bitstring(activity_id), do: "/checkpoint/activity/" <> form_id <> "/" <> activity_id
  defp get_parent_record(s, p) do
    p = objectify_map(p)
    activity = nil;
    {api_status, res} = api_get_json api_form_parent_method(p.activity_id), s.auth_token, s.account_type
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        activity = record.description
      end
    end
    form = nil;
    {api_status, res} = api_get_json api_form_activity_method(p.form_id, p.activity_id), s.auth_token, s.account_type
    if(api_status == :ok) do
      record = objectify_map res.body.res
      if res.body.status do
        form = record.description
      end
    end
    %{ form_id: p.form_id, activity_id: p.activity_id, form: form, activity: activity }
  end

end
