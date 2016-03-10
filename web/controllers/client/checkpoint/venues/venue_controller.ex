defmodule CentralGPSWebApp.Client.Checkpoint.VenueController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /checkpoint/venues/create
  # GET     /checkpoint/venues/:venue_id
  # PUT     /checkpoint/venues/:venue_id
  # DELETE  /checkpoint/venues/:venue_id
  # GET     /checkpoint/venues
  # GET     /checkpoint/venues/json

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
  defp image_dir, do: "images/checkpoint/venue"
  defp image_placeholder, do: Enum.join([image_dir, centralgps_placeholder_file], "/")
  defp api_method(action \\ "") when is_bitstring(action), do: "/checkpoint/venue/" <> action
  
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
        rows = res.body.rows
          |> Enum.map(&(objectify_map &1))
          |> Enum.map &(%{id: &1.id, configuration_id: &1.configuration_id, creator: &1.creator,
          active: &1.active, name: &1.name, code: &1.code, description: &1.description, address: &1.address,
          image_path: (if (&1.image_path != nil), do: &1.image_path, else: image_placeholder),
          lat: &1.lat, lon: &1.lon, detection_radius: &1.detection_radius })
      else
        res = Map.put res, :body, %{ status: false, msg: (if Map.has_key?(res, :activity), do: res.activity, else: res.body.msg) }
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    Map.merge (res.body |> Map.put :rows, rows), p
  end

  defp get_record(s, p) do
    p = objectify_map p
    {api_status, res} = api_get_json api_method(p.id), s.auth_token, s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map(res.body.res)
      image = if (record.image_path != nil), do: record.image_path, else: image_placeholder
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg},
          %{id: record.id, client_id: record.client_id, venue_type_id: record.venue_type_id, configuration_id: record.configuration_id,
          active: record.active, name: record.name, code: record.code, description: record.description, address: record.address,
          image_path: image, lat: record.lat, lon: record.lon,
          detection_radius: record.detection_radius, xtra_info: record.xtra_info, creator: record.creator}
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
    if (!Map.has_key?p, :client_id), do: p = Map.put(p, :client_id, nil)
    if (!Map.has_key?p, :active),
      do: p = Map.put( p, :active, false),
      else: p = Map.update(p, :active, false, &(&1 == "on"))
    if (!Map.has_key?(p, :xtra_info) || p.xtra_info == ""), do: p = Map.put p, :xtra_info, nil
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
      data = %{ venue_id: p.id, client_id: p.client_id, venue_type_id: p.venue_type_id, active: p.active,
        configuration_id: s.configuration_id, name: p.name, code: p.code, address: p.address,
        description: p.description, lat: p.lat, lon: p.lon, image_path: Enum.join([image_dir, image_path], "/"), image_bin: file,
        detection_radius: p.detection_radius, xtra_info: p.xtra_info }
      {api_status, res} = api_put_json api_method(data.venue_id), s.auth_token, s.account_type, data
      if api_status == :ok && res.body.status do
        local_save_image(p.image, p.image_path)
      else
        res = Map.put res, :body, %{ status: false, msg: res.reason }
      end
    else
      file = nil
      if (p.image != nil) do
        image_path = (UUID.uuid4 <> "." <> (String.split(upload_file_name(p.image), ".") |> List.last))
          |> String.replace( "/", "")
        image_path = Enum.join [image_dir, image_path], "/"
        {:ok, file} = File.read p.image.path
        file = Base.url_encode64(file)
      else
        image_path = image_placeholder
      end
      data = %{ client_id: p.client_id, venue_type_id: p.venue_type_id, configuration_id: s.configuration_id,
        active: p.active, name: p.name, code: p.code, description: p.description, address: p.address,
        lat: p.lat, lon: p.lon, image_path: image_path, image_bin: file,
        detection_radius: p.detection_radius, xtra_info: p.xtra_info }
      {api_status, res} = api_post_json api_method("create"), s.auth_token, s.account_type, data
      if api_status == :ok do
        if res.body.status do
          local_save_image(p.image, data.image_path)
        else
          res = Map.put res, :body, %{ status: false, msg: res.body.msg }
        end
      else
        res = Map.put res, :body, %{ status: false, msg: res.reason }
      end
    end
    res.body #let's return the message
  end

  defp local_save_image(image, image_path) do
    if (image != nil) do #put the corresponding pic for the record.
      dest_dir = Enum.join [priv_static_path, image_dir], "/"
      File.rm Enum.join([dest_dir, String.split(image_path, image_dir) |> List.last], "/") #removes the old image
      File.mkdir_p dest_dir
      File.copy(image.path, Enum.join([dest_dir,  image_path], "/"), :infinity)
    end
  end
end
