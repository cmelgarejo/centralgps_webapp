defmodule CentralGPSWebApp.Client.LoginController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.Repo.Utilities
  import CentralGPS.RestClient
  import CentralGPSWebApp
  plug :action

  defp login_data_builder(_p) do
    %{
      _login_user: base64_encode("#{_p["username"]}@#{_p["domain"]}@#{app_config(:entity_tag)}"),
      _password:   base64_encode(_p["password"])
    }
  end

  def index(conn, _params) do
    render conn |> put_layout("login_template.html"), "login.html"
  end

  def login(conn, _params) do
    #IO.puts "login_data: #{inspect login_data_builder(_params)}"
    {status, res} = login_api_post_json "C", login_data_builder(_params)
    if status == :ok do
      status = res.status_code
      res = res.body
      case status do
        201 -> conn = centralgps_start_session(conn, res.res |> objectify_map)
               res = res |> Map.put(:res, main_url(Endpoint, :index))
          _ -> nil
      end
    else # if :error
      res = %{ status: false, msg: res.reason, res: res}
    end
    json conn, res
  end

  def logout(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else
      {status, res} = logout_api_post_json session.auth_token, session.account_type
      if status == :ok do
        status = res.status_code
        case status do
          200 -> res = res.body |> objectify_map
                 #IO.puts "logout:res = #{inspect res}"
                 if(res.status == true) do
                   conn = centralgps_kill_session(conn)
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
