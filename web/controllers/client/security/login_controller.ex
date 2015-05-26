defmodule CentralGPSWebApp.Client.LoginController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.Repo.Utilities
  import CentralGPS.RestClient
  import CentralGPSWebApp
  plug :action

  def index(conn, _params) do
    render conn |> put_layout("login_template.html"), "login.html"
  end

  def login(conn, _params) do
    #IO.puts "#{_params["username"]}@##{_params["domain"]}@#{app_config(:entity_tag)}"
    {status, res} = login_api_post_json "C",
      Poison.encode!(%{
        _login_user:
              base64_encode("#{_params["username"]}@#{_params["domain"]}@#{app_config(:entity_tag)}"),
        _password:   base64_encode(_params["password"])
      }),
      [ {"Content-Type", "application/json;charset=utf-8"} ]
    if status == :ok do
      status = res.status_code
      res = res.body
      case status do
        201 -> conn = put_session conn, :session_data, res.res |> objectify_map
               res = res |> Map.put(:res, main_url(Endpoint, :index))
        _   -> nil
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
      {status, res} = logout_api_post_json session.auth_token, "C"
      if status == :ok do
        status = res.status_code
        case status do
          200 -> res = res.body |> objectify_map
            _ -> nil
        end
        IO.puts "logout res: #{inspect res}"
        redirect conn, to: login_path(Endpoint, :index)
      else # if :error
        IO.puts "logout res: #{inspect res}"
        redirect conn, to: login_path(Endpoint, :index)
      end
    end
  end

end
