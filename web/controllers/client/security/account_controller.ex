defmodule CentralGPSWebApp.Client.Security.AccountController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /security/account/create
  # GET     /security/account/:account_id
  # PUT     /security/account/:account_id
  # DELETE  /security/account/:account_id
  # GET     /security/account
  # GET     /security/account/json

  # PUT     /api/v1/security/account/activate/:account_type/:account_id
  # POST    /api/v1/security/account/create/:account_type
  # GET     /api/v1/security/account/:account_type/:account_id
  # PUT     /api/v1/security/account/:account_type/:account_id
  # DELETE  /api/v1/security/account/:account_type/:account_id
  # GET     /api/v1/security/account
  # POST    /api/v1/security/account/:account_type/:account_id/roles/create/:role_id
  # DELETE  /api/v1/security/account/:account_type/:account_id/roles/:role_id
  # POST    /api/v1/security/account/:account_type/:account_id/permissions/create/:permission_id
  # DELETE  /api/v1/security/account/:account_type/:account_id/permissions/:permission_id

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
      render (conn |> assign(:image_placeholder, image_placeholder)), "new.html"
    end
  end

  def edit(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render (conn |> assign(:record, get_record(session, params))), "edit.html"
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
  defp image_dir(client_id \\ ""), do: "images/client/#{client_id}/account"
  defp image_placeholder, do: String.replace(Enum.join([image_dir, centralgps_placeholder_file], "/"), "//", "/")
  defp api_method(account_type \\ "", action \\ "") when is_bitstring(action), do:
    String.replace(Enum.join(["/security/account/", account_type, action], "/"), "//", "/")

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
          |> Enum.map(&(%{id: &1.id, account_type: &1.account_type, name: &1.name,
          identity_document: &1.identity_document, login_name: &1.username,
          dob: &1.dob, emails: &1.emails, phones: &1.phones,
          timezone: &1.timezone, active: &1.active, blocked: &1.blocked,
          language_template: &1.language_template, image_path: &1.image_path,
          activated_at: &1.activated_at, deactivated_at: &1.deactivated_at,
          created_at: &1.created_at, updated_at: &1.updated_at }))
      else
        res = Map.put res, :body, %{ status: false, msg: (if Map.has_key?(res, :activity), do: res.activity, else: res.body.msg) }
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    Map.merge (res.body |> Map.put(:data, rows)), p
  end

  defp get_record(s, p) do
    p = objectify_map p
    {api_status, res} = api_get_json api_method(p.account_type, p.id), s.auth_token, s.account_type
    if(api_status == :ok) do
      record = objectify_map(res.body)
      if Map.has_key?(record, :res) do
        record = objectify_map(res.body.res)
        if res.body.status do
          Map.merge %{status: res.body.status, msg: res.body.msg} , #record
          %{id: record.id, account_type: record.account_type, name: record.name, identity_document: record.identity_document,
          login_name: record.username, dob: record.dob, emails: record.emails, phones: record.phones,
          timezone: record.timezone, active: record.active, blocked: record.blocked,
          language_template: record.language_template, image_path: record.image_path,
          activated_at: record.activated_at, deactivated_at: record.deactivated_at,
          created_at: record.created_at, updated_at: record.updated_at,
          xtra_info: record.xtra_info}
        end
      end
    else
      Map.put res, :body, %{ status: false, msg: res.reason }
    end
  end

  defp delete_record(s, p) do
    p = objectify_map p
    if(Map.has_key?(p, :id) && Map.has_key?(p, :account_type)) do
      {api_status, res} =
        api_delete_json api_method(p.account_type, p.id),
        s.auth_token, s.account_type
      if(api_status == :ok) do
        if !res.body.status, do: res = Map.put res, :body, %{ status: false, msg: res.body.msg }
      else
        res = Map.put res, :body, %{ status: false, msg: res.reason }
      end
      res.body
    else
      {api_status, res} = {:error, %{body: %{ status: false, msg: "no id - controller err"}}}
      res = Map.put res, :body, %{ status: false, msg: res.reason }
      res.body
    end
  end

  defp save_record(s, p) do
    p = objectify_map(p)
    language_template_id = 2 #TODO: remove this! :(
    if (!Map.has_key?(p, :login_password) || p.login_password == ""), do: p = Map.put p, :login_password, nil
    if (!Map.has_key?p, :__form__), do: p = Map.put p, :__form__, :edit
    if (!Map.has_key?(p, :xtra_info) || p.xtra_info == ""), do: p = Map.put p, :xtra_info, nil
    if (!Map.has_key?(p, :account_type)), do: p = Map.put p, :account_type, "C"
    if (!Map.has_key?p, :image), do: p = Map.put(p, :image, nil), else:
      (if p.image == "", do: p = Map.put p, :image, nil) #if the parameter is there and it's empty, let's just NIL it :)
    if (!Map.has_key?p, :active),
      do: p = Map.put( p, :active, false),
      else: p = Map.update(p, :active, false, &(&1 == "on"))
    if (!Map.has_key?p, :blocked),
      do: p = Map.put( p, :blocked, false),
      else: p = Map.update(p, :blocked, false, &(&1 == "on"))
    file = nil
    v_image_path = nil
    if (p.image != nil && v_image_path == nil) do #let's create a hash filename for the new pic.
      v_image_path = (UUID.uuid4 <> "." <> (String.split(upload_file_name(p.image), ".") |> List.last)) |> String.replace("/", "")
      {:ok, file} = File.read p.image.path
      file = Base.url_encode64(file)
    else #or take the already existing one
      v_image_path = (String.split(p.image_path, image_dir(s.client_id)) |> List.last) |> String.replace("/", "")
    end
    account_type = s.account_type
    action = "create"
    data = %{ empty: true }
    if (String.to_atom(p.__form__) ==  :edit) do
      data = %{ account_id: p.id, account_type: p.account_type, login_password: p.login_password, dob: p.dob, identity_document: p.identity_document,
        image_path: Enum.join([image_dir(s.client_id), v_image_path], "/"), image_bin: file,
        info_emails: p.emails, info_phones: p.phones, language_template_id: language_template_id, name: p.name, timezone: p.timezone, xtra_info: p.xtra_info }
      account_type = data.account_type
      action = data.account_id
    else
      data = %{ client_id: s.client_id, account_type: p.account_type, login_name: p.login_name, login_password: p.login_password, dob: p.dob, identity_document: p.identity_document,
        image_path: Enum.join([image_dir(s.client_id), v_image_path], "/"), image_bin: file,
        info_emails: p.emails, info_phones: p.phones, language_template_id: language_template_id, name: p.name, timezone: p.timezone, xtra_info: p.xtra_info }
    end
    {api_status, res} = api_post_json api_method(action, account_type), s.auth_token, s.account_type, data
    if api_status == :ok do
      if res.body.status && (p.image != nil) do #put the corresponding pic for the record.
        dest_dir = Enum.join [priv_static_path, image_dir(s.client_id)], "/"
        File.rm Enum.join([dest_dir,  String.split(v_image_path, image_dir(s.client_id)) |> List.last], "/") #removes the old image
        File.mkdir_p dest_dir
        File.copy(p.image.path, Enum.join([dest_dir, v_image_path], "/"), :infinity)
      end
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    res.body #let's return the message
  end
end
