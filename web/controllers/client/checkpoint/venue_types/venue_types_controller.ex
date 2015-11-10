defmodule CentralGPSWebApp.Client.Checkpoint.VenueTypeController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /checkpoint/venue_types/create
  # GET     /checkpoint/venue_types/:venue_id
  # PUT     /checkpoint/venue_types/:venue_id
  # DELETE  /checkpoint/venue_types/:venue_id
  # GET     /checkpoint/venue_types
  # GET     /checkpoint/venue_types/json

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
      render (conn |> assign :image_placeholder, image_placeholder), "new.html"
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
  defp image_dir, do: "images/checkpoint/venue_type"
  defp image_placeholder, do: Enum.join([image_dir, centralgps_placeholder_file], "/")
  defp api_method(action \\ "") when is_bitstring(action), do: "/checkpoint/venue_type/" <> action

  defp get_record(s, p) do
    p = objectify_map p
    {api_status, res} = api_get_json api_method(p.id), s.auth_token, s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map(res.body.res)
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg} ,
          %{id: record.id, configuration_id: record.configuration_id, description: record.description,
          image_path: record.image_path }
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    record
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
      if !res.body.status, do: res = Map.put res, :body, %{ status: false, msg: res.body.msg }
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    res.body
  end

  defp save_record(s, p) do
    p = objectify_map(p)
    if (!Map.has_key?p, :__form__), do: p = Map.put p, :__form__, :edit
    if (!Map.has_key?p, :image), do: p = Map.put(p, :image, nil), else:
      (if p.image == "", do: p = Map.put p, :image, nil) #if the parameter is there and it's empty, let's just NIL it :)
    if (String.to_atom(p.__form__) ==  :edit) do
      file = nil
      if (p.image != nil) do #let's create a hash filename for the new pic.
        image_path = (UUID.uuid4 <> "." <> (String.split(upload_file_name(p.image), ".") |> List.last)) |> String.replace "/", ""
        {:ok, file} = File.read p.image.path
        file = Base.url_encode64(file)
      else #or take the already existing one
        image_path = (String.split(p.image_path, image_dir) |> List.last) |> String.replace "/", ""
      end
      data = %{ venue_id: p.id, configuration_id: s.client_id, description: p.description,
        image_path: Enum.join([image_dir, image_path], "/"), image_bin: file  }
      {api_status, res} = api_put_json api_method(data.venue_id), s.auth_token, s.account_type, data
      if api_status == :ok  do
        if res.body.status && (p.image != nil) do #put the corresponding pic for the record.
          dest_dir = Enum.join [priv_static_path, image_dir], "/"
          File.rm Enum.join([dest_dir,  String.split(p.image_path, image_dir) |> List.last], "/") #removes the old image
          File.mkdir_p dest_dir
          File.copy(p.image.path, Enum.join([dest_dir,  image_path], "/"), :infinity)
        end
      else
        res = Map.put res, :body, %{ status: false, msg: res.reason }
      end
    else
      file = nil
      if (p.image != nil) do
        image_path = (UUID.uuid4 <> "." <> (String.split(upload_file_name(p.image), ".") |> List.last)) |> String.replace "/", ""
        {:ok, file} = File.read p.image.path
        file = Base.url_encode64(file)
      else
        image_path = image_placeholder
      end
      data = %{ configuration_id: s.client_id, description: p.description,
        image_path: image_path, image_bin: file  }
      {_, res} = api_post_json api_method("create"), s.auth_token, s.account_type, data
    end
    res.body #return the message
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
        rows = res.body.rows |> Enum.map(&(objectify_map &1)) #|> Enum.map &(%{id: &1.id, description: &1.description, image_path: &1.image_path })
      else
        res = Map.put res, :body, %{ status: false, msg: (if Map.has_key?(res, :activity), do: res.activity, else: res.body.msg) }
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    Map.merge (res.body |> Map.put :rows, rows), p
  end

end
