defmodule CentralGPSWebApp.Client.ProfileController do
  use CentralGPSWebApp.Web, :controller


  def index(conn, _) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render conn, "profile.html"
    end
  end

end
