defmodule CentralGPSWebApp.Client.LoginController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.Repo.Utilities
  import CentralGPS.RestClient
  import CentralGPSWebApp

  defp login_data_builder(p) do
    %{
      _login_user: base64_encode("#{p.username}@#{p.domain}@#{app_config(:entity_tag)}"),
      _password:   base64_encode(p.password)
    }
    # %{
    #   _login_user: base64_encode("#{p["username"]}@#{p["domain"]}@#{app_config(:entity_tag)}"),
    #   _password:   base64_encode(p["password"])
    # }
  end

  def index(conn, _) do
    render conn |> put_layout("login_template.html"), "login.html"
  end

  def login(conn, params) do
    {status, res} = login_api_post_json "C", login_data_builder(objectify_map params)
    if status == :ok do
      status = res.status_code
      res = res.body
      case status do
        201 ->
              filter_keys = [ :auth_token, :activated_at, :client_profile_image, :created_at, :dob, :emails, :entity_profile_image, :identity_document, :language_code, :name, :permissions, :profile_image, :phones, :roles, :timezone, :updated_at, :username, :xtra_info ]
              poop = res.res  |> objectify_map |> Map.take filter_keys
              conn = centralgps_startsession(conn, res.res  |> objectify_map |> Map.take filter_keys)
              res = res |> Map.put(:res, main_url(Endpoint, :index))
          _ -> nil
      end
    else # if :error
      res = %{ status: false, msg: res.reason, res: res}
    end
    json conn, res
  end

  def logout(conn, _) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else
      {status, res} = logout_api_post_json session.auth_token, session.account_type
      if status == :ok do
        status = res.status_code
        case status do
          200 -> res = res.body |> objectify_map
                 if(res.status == true) do
                   conn = centralgps_killsession(conn)
                 end
            _ -> nil
        end
        redirect conn, to: login_path(Endpoint, :index)
      else # if :error
        redirect conn, to: login_path(Endpoint, :index)
      end
    end
  end

end
