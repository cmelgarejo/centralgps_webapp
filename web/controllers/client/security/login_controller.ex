defmodule CentralGPSWebApp.Client.LoginController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.Repo.Utilities
  plug :action

  def index(conn, _params) do
    user_data = get_session conn, :user_data
    IO.puts "user: #{inspect user_data}"
    conn = conn |> assign(:user_data, "poop")
    render conn |> put_layout("oob.html"), "login.html"
  end

  def login(conn, _params) do
    {status, res} = CentralGPSWebApp.HttpClient.post "/security/login/C",
    Poison.encode!(%{
      _login_user: base64_encode(_params["username"]),
      _password: base64_encode(_params["password"])
    }), [ {"Content-Type", "application/json;charset=utf-8"} ]
    IO.puts "res: #{inspect res}"
    if status == :ok do
      {status, res} = {res.status_code, res.body}
      case status do
        201 -> put_session conn, :user_data, res
        _ -> nil
      end
    else
      res = "#{inspect res}"
    end
    json conn, %{status: status, msg: res}
    #render conn |> put_layout("oob.html"), "login.html"
  end

end
