defmodule CentralGPSWebApp.Client.Security.AccountController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /security/accounts/create
  # GET     /security/accounts/:account_id
  # PUT     /security/accounts/:account_id
  # DELETE  /security/accounts/:account_id
  # GET     /security/accounts
  # GET     /security/accounts/json

  # PUT     /api/v1/security/accounts/activate/:account_type/:account_id
  # POST    /api/v1/security/accounts/create/:account_type
  # GET     /api/v1/security/accounts/:account_type/:account_id
  # PUT     /api/v1/security/accounts/:account_type/:account_id
  # DELETE  /api/v1/security/accounts/:account_type/:account_id
  # GET     /api/v1/security/accounts
  # POST    /api/v1/security/accounts/:account_type/:account_id/roles/create/:role_id
  # DELETE  /api/v1/security/accounts/:account_type/:account_id/roles/:role_id
  # POST    /api/v1/security/accounts/:account_type/:account_id/permissions/create/:permission_id
  # DELETE  /api/v1/security/accounts/:account_type/:account_id/permissions/:permission_id

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
  defp image_dir, do: "images/account"
  defp image_placeholder, do: Enum.join([image_dir, centralgps_placeholder_file], "/")
  defp api_method(account_type \\ "", action \\ "") when is_bitstring(action), do:
    "/security/accounts/" <> account_type <> "/" <> action

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
          |> Enum.map &(%{id: &1.id, account_type: &1.account_type, name: &1.name,
          identity_document: &1.identity_document, username: &1.username,
          dob: &1.dob, emails: &1.emails, phones: &1.phones,
          timezone: &1.timezone, active: &1.active, blocked: &1.blocked,
          language_template: &1.language_template, profile_image: &1.profile_image,
          activated_at: &1.activated_at, deactivated_at: &1.deactivated_at,
          created_at: &1.created_at, updated_at: &1.updated_at })
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    Map.merge (res.body |> Map.put :rows, rows), _p
  end

  defp get_record(_s, _p) do
    _p = objectify_map _p
    {api_status, res} = api_get_json api_method(_p.account_type, _p.id), _s.auth_token, _s.account_type
    record = nil
    if(api_status == :ok) do
      record = objectify_map(res.body)
      if Map.has_key?(record, :res) do
        record = objectify_map(res.body.res)
        if res.body.status do
          record = Map.merge %{status: res.body.status, msg: res.body.msg} , record
          #%{id: record.id, name: record.name, identity_document: record.identity_document,
          #username: record.username, dob: record.dob, emails: record.emails, phones: record.phones,
          #timezone: record.timezone, active: record.active, blocked: record.blocked,
          #language_template: record.language_template, profile_image: record.profile_image,
          #activated_at: record.activated_at, deactivated_at: record.deactivated_at,
          #created_at: record.created_at, updated_at: record.updated_at,
          #xtra_info: record.xtra_info}
        end
      end
    else
      record = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    record
  end

  defp delete_record(_s, _p) do
    _p = objectify_map _p
    if(Map.has_key?(_p, :id) && Map.has_key?(_p, :account_type)) do
      {api_status, res} =
        api_delete_json api_method(_p.account_type, _p.id),
        _s.auth_token, _s.account_type
    else
      {api_status, res} = {:error, %{body: %{ status: false, msg: "no id - controller err"}}}
    end
    if(api_status == :ok) do
      if !res.body.status, do: res = Map.put res, :body, %{ status: false, msg: res.body.msg }
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    res.body
  end

  defp save_record(_s, _p) do
    _p = objectify_map(_p)
    if (!Map.has_key?_p, :__form__), do: _p = Map.put _p, :__form__, :edit
    if (!Map.has_key?(_p, :xtra_info) || _p.xtra_info == ""), do: _p = Map.put _p, :xtra_info, nil
    if (!Map.has_key?_p, :image), do: _p = Map.put(_p, :image, nil), else:
      (if _p.image == "", do: _p = Map.put _p, :image, nil) #if the parameter is there and it's empty, let's just NIL it :)
    if (String.to_atom(_p.__form__) ==  :edit) do
      #image_filename = _p.profile_image
      file = nil
      if (_p.image != nil) do #let's create a hash filename for the new pic.
        image_filename = (UUID.uuid4 <> "." <> (String.split(upload_file_name(_p.image), ".") |> List.last)) |> String.replace "/", ""
        {:ok, file} = File.read _p.image.path
        file = Base.url_enidentity_document64(file)
      else #or take the already existing one
        image_filename = (String.split(_p.profile_image, image_dir) |> List.last) |> String.replace "/", ""
      end
      data = %{ account_id: _p.id, account_type_id: _p.account_type_id,
        configuration_id: _s.client_id, name: _p.name, identity_document: _p.identity_document,
        description: _p.description, lat: _p.lat, lon: _p.lon, profile_image: image_filename,
        image: Enum.join([image_dir, image_filename], "/"), image_file: file,
        detection_radius: _p.detection_radius, xtra_info: _p.xtra_info }
      {api_status, res} = api_put_json api_method(data.account_type, data.id), _s.auth_token, _s.account_type, data
      if api_status == :ok  do
        if res.body.status && (_p.image != nil) do #put the corresponding pic for the record.
          dest_dir = Enum.join [Utilities.priv_static_path, image_dir], "/"
          File.rm Enum.join([dest_dir,  String.split(_p.profile_image, image_dir) |> List.last], "/") #removes the old image
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
        file = Base.url_enidentity_document64(file)
      else
        image_filename = image_placeholder
      end
      data = %{ account_type_id: _p.account_type_id, configuration_id: _s.client_id,
        name: _p.name, identity_document: _p.identity_document, description: _p.description,
        lat: _p.lat, lon: _p.lon, image: image_filename, image_file: file,
        detection_radius: _p.detection_radius, xtra_info: _p.xtra_info }
      {_, res} = api_post_json api_method(_p.account_type, "create"), _s.auth_token, _s.account_type, data
    end
    res.body #let's return the message
  end

end
