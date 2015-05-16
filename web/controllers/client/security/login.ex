defmodule CentralGPSWebApp.Client.LoginController do
  use CentralGPSWebApp.Web, :controller
  #import CentralGPSWebApp
  plug :action

  def login(conn, _params) do
    #CentralGPSWebApp.HttpClient.start
    # response = nil
    # {ok, response} = HttpClient.get("/device/venues",
    # [{"Authorization", "CentralGPS token=b451717ffeb3006805bcc88d99cbc86f6e73795c,type=A"}],
    # [ hackney: [:insecure] ])
    # IO.puts "#{inspect response}"
    # r = (if ok == :ok, do: (hd  response.body[:list_update])["name"], else: response)
    # conn = conn
    # |> assign(:json_result, r)
    render conn, "login.html"
  end
end
