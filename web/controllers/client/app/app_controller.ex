defmodule CentralGPSWebApp.Client.AppController do
  use CentralGPSWebApp.Web, :controller
  #import CentralGPS.Repo.Utilities
  #import CentralGPSWebApp
  plug :action

  def index(conn, _params) do
    user_data = get_session(conn, :user_data)
    if (user_data != nil) do
      IO.puts "#{inspect user_data}"
      conn = conn
        |> assign(:language, user_data.language_code)
        |> assign(:name, user_data.name)
        |> assign(:entity_profile_image, if(user_data.entity_profile_image != nil, do: user_data.entity_profile_image, else: "images/entity/_placeholder.png"))
        |> assign(:client_profile_image, if(user_data.client_profile_image != nil, do: user_data.client_profile_image, else: "images/profile-menu.png"))
        |> assign(:profile_image, if(user_data.profile_image != nil, do: user_data.profile_image, else: "images/profile/_placeholder.png"))
      #render conn, "app.html"
      render conn |> put_layout("t.main.html"), "app.html"
    else
      redirect conn, to: login_path(Endpoint, :index)
    end
  end

end
