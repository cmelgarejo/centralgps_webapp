defmodule CentralGPSWebApp.Utilities do
  #import Phoenix.Controller, only: [get_csrf_token: 0]
  import Plug.Conn, only: [get_session: 2, put_session: 3, assign: 3]

  def csrf_token_tag do
    # raw """
    # <input type="hidden" name="_csrf_token" value="<%= get_csrf_token  %>">
    # """
  end

  def centralgps_start_session(conn, session_data) do
    put_session(conn, :session_data, session_data)
  end

  def centralgps_kill_session(conn) do
    put_session(conn, :session_data, nil)
  end

  @doc """
  Assigns the session to the current Plug.conn
  """
  def centralgps_session(conn) do
    session = get_session(conn, :session_data)
    if (session != nil) do
      IO.puts "session: #{inspect session.auth_token}"
      conn = conn
        |> assign(:session, session)
        |> assign(:profile_image, if(session.profile_image != nil, do: session.profile_image, else: "images/profile/_placeholder.png"))
        |> assign(:entity_profile_image, if(session.entity_profile_image != nil, do: session.entity_profile_image, else: "images/entity/_placeholder.png"))
        |> assign(:client_profile_image, if(session.client_profile_image != nil, do: session.client_profile_image, else: "images/profile-menu.png"))
      {conn, session}
    else
      {conn, :error}
    end
  end
end
