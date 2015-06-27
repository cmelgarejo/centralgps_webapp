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
      render (conn |> assign :image_placeholder, image_placeholder), "new.html"
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
  defp image_dir, do: "images/venue_type"
  defp image_placeholder, do: Enum.join([image_dir, centralgps_placeholder_file], "/")
  defp api_method(action \\ "") when is_bitstring(action), do: "/checkpoint/venue_types/" <> action
  defp list_records(_s, _p) do
    _p = objectify_map(_p)
      |> (Map.update :current, 1, fn(v)->(if !is_integer(v), do: elem(Integer.parse(v), 0), else: v) end)
      |> (Map.update :rowCount, 10, fn(v)->(if !is_integer(v), do: elem(Integer.parse(v), 0), else: v) end)
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
          |> Enum.map &(%{id: &1.id, description: &1.description, venue_type_image: &1.venue_type_image })
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    Map.merge (res.body |> Map.put :rows, rows), _p
  end

  defp get_record(_s, _p) do
    _p = objectify_map _p
    {api_status, res} = api_get_json api_method(_p.id), _s.auth_token, _s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map(res.body.res)
      if res.body.status do
        record = Map.merge %{status: res.body.status, msg: res.body.msg} ,
          %{id: record.id, configuration_id: record.configuration_id, description: record.description,
          image_filename: record.venue_type_image }
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    record
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
      if !res.body.status, do:
        res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    res.body
  end


  defp save_record(_s, _p) do
    _p = objectify_map(_p)
    if (!Map.has_key?_p, :__form__), do: _p = Map.put _p, :__form__, :edit
    if (!Map.has_key?_p, :image), do: _p = Map.put(_p, :image, nil), else:
    (if _p.image == "", do: _p = Map.put _p, :image, nil) #if the parameter is there and it's empty, let's just NIL it :)
    if (String.to_atom(_p.__form__) ==  :edit) do
      #image_filename = _p.image_filename
      file = nil
      if (_p.image != nil) do #let's create a hash filename for the new pic.
        image_filename = (UUID.uuid4 <> "." <> (String.split(upload_file_name(_p.image), ".") |> List.last)) |> String.replace "/", ""
        {:ok, file} = File.read _p.image.path
        file = Base.url_encode64(file)
      else #or take the already existing one
        image_filename = (String.split(_p.image_filename, image_dir) |> List.last) |> String.replace "/", ""
      end
      data = %{ venue_id: _p.id, configuration_id: _s.client_id, description: _p.description,
        image: Enum.join([image_dir, image_filename], "/"), image_file: file  }
      {api_status, res} = api_put_json api_method(data.venue_id), _s.auth_token, _s.account_type, data
      if api_status == :ok  do
        if res.body.status && (_p.image != nil) do #put the corresponding pic for the record.
          dest_dir = Enum.join [Utilities._priv_static_path, image_dir], "/"
          File.rm Enum.join([dest_dir,  String.split(_p.image_filename, image_dir) |> List.last], "/") #removes the old image
          #IO.puts "#{inspect dest_dir}"
          File.mkdir_p dest_dir
          File.copy(_p.image.path, Enum.join([dest_dir,  image_filename], "/"), :infinity)
        end
      else
        res = Map.put res, :body, %{ status: false, msg: res.reason }
      end
    else
      file = nil
      if (_p.image != nil) do
        image_filename = (UUID.uuid4 <> "." <> (String.split(upload_file_name(_p.image), ".") |> List.last)) |> String.replace "/", ""
        {:ok, file} = File.read _p.image.path
        file = Base.url_encode64(file)
      else
        image_filename = image_placeholder
      end
      data = %{ configuration_id: _s.client_id, description: _p.description,
        image: image_filename, image_file: file  }
      {_, res} = api_post_json api_method("create"), _s.auth_token, _s.account_type, data
    end
    res.body #return the message
  end
end