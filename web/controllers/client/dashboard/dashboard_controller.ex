defmodule CentralGPSWebApp.Client.DashboardController do
  use CentralGPSWebApp.Web, :controller


  def index(conn, _params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      render conn, "dashboard.html"
    end
  end

end
