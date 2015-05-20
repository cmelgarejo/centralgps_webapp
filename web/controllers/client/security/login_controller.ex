defmodule CentralGPSWebApp.Client.LoginController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.Repo.Utilities
  import CentralGPSWebApp
  plug :action

  def index(conn, _params) do
    #user_data = get_session(conn, :user_data)
    #conn = conn |> assign(:user_data, (if (user_data != nil), do: (user_data), else: "poop"))
    render conn |> put_layout("t.login.html"), "login.html"
  end

  def login(conn, _params) do
    {status, res} = CentralGPS.RestClient.post "/security/login/C",
    Poison.encode!(%{
      _login_user: base64_encode("#{_params["username"]}#{app_config(:entity_tag)}"),
      _password: base64_encode(_params["password"])
    }), [ {"Content-Type", "application/json;charset=utf-8"} ]
    if status == :ok do
      case status do
        201 -> conn = put_session conn, :user_data, res.body
        _ -> nil
      end
    #else
    #  res = %{ status: false, msg: nil}
    end
    json conn, res.body
    #render conn |> put_layout("oob.html"), "login.html"
  end

end
