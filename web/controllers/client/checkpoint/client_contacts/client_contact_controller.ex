defmodule CentralGPSWebApp.Client.Checkpoint.ClientContactController do
    use CentralGPSWebApp.Web, :controller
    import CentralGPS.RestClient
    import CentralGPS.Repo.Utilities

    # POST    /api/v1/checkpoint/client/:client_id/contact/create
    # GET     /api/v1/checkpoint/client/:client_id/contact/:client_contact_id
    # PUT     /api/v1/checkpoint/client/:client_id/contact/:client_contact_id
    # DELETE  /api/v1/checkpoint/client/:client_id/contact/:client_contact_id
    # GET     /api/v1/checkpoint/client/:client_id/contact

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
        render (conn |> assign(:parent_record, get_parent_record(session, params)) |> assign(:image_placeholder, image_placeholder)), "new.html"
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
    defp image_dir, do: "images/checkpoint/client/contact"
    defp image_placeholder, do: Enum.join([image_dir, centralgps_placeholder_file], "/")
    defp api_method(client_id, form \\ "") do
      if !is_bitstring(client_id), do: client_id = Integer.to_string(client_id)
      "/checkpoint/client/" <> client_id <> "/contact/" <> form
    end

    defp get_record(s, p) do
      p = objectify_map(p)
      {api_status, res} = api_get_json api_method(p.client_id, p.id), s.auth_token, s.account_type
      record = nil
      if(api_status == :ok) do
        record = objectify_map res.body.res
        Map.merge record, %{ client_id: p.client_id }
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
        if (!Map.has_key?p, :notify), do: p = Map.put( p, :notify, false), else: p = Map.update(p, :notify, false, &(&1 == "on"))
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
          data = %{ client_contact_id: p.id, client_id: p.client_id, name: p.name, notes: p.notes,
            emails: p.emails, phones: p.phones, notify: p.notify, image_path: Enum.join([image_dir, image_path], "/"),
            image_bin: file }
          {api_status, res} = api_put_json api_method(data.client_id, data.client_contact_id), s.auth_token, s.account_type, data
          if api_status == :ok do
            if res.body.status do
              local_save_image(p.image, data.image_path)
            else
              res = Map.put res, :body, %{ status: false, msg: res.body.msg }
            end
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
          data = %{ client_id: p.client_id, name: p.name, notes: p.notes,
            emails: p.emails, phones: p.phones, notify: p.notify, image_path: image_path, image_bin: file }
          {api_status, res} = api_post_json api_method(data.client_id, "create"), s.auth_token, s.account_type, data
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
        res.body
      rescue
        e in _ -> %{ status: false, msg: error_logger(e, __ENV__) }
      end
    end

    defp local_save_image(image, image_path) do
      if (image != nil) do #put the corresponding pic for the record.
        dest_dir = Enum.join [priv_static_path, image_dir], "/"
        File.rm Enum.join([dest_dir, String.split(image_path, image_dir) |> List.last], "/") #removes the old image
        File.mkdir_p dest_dir
        File.copy(image.path, Enum.join([dest_dir,  image_path], "/"), :infinity)
      end
    end

    defp delete_record(s, p) do
      p = objectify_map p
      if(Map.has_key?p, :id) do
        {api_status, res} =
          api_delete_json api_method(p.client_id, p.id),
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
        |> (Map.update :client_id, 0, &(parse_int(&1)))
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
        sort_column: p.sort_column, sort_order: p.sort_order, client_id: p.client_id}
      {api_status, res} = api_get_json api_method(p.client_id), s.auth_token, s.account_type, qs
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

    defp api_parent_method(form) when is_bitstring(form), do: "/checkpoint/client/" <> form
    defp get_parent_record(s, p) do
      p = objectify_map(p)
      {api_status, res} = api_get_json api_parent_method(p.client_id), s.auth_token, s.account_type
      record = %{id: 0}
      if(api_status == :ok) do
        record = objectify_map res.body.res
        if res.body.status do
          record = Map.merge %{status: res.body.status, msg: res.body.msg},
            %{ id: record.id, client_id: record.id, name: record.name, description: record.description,
              xtra_info: record.xtra_info }
        end
      end
      record
    end
  end
