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

  def centralgps_session(conn) do
    session = get_session(conn, :session_data)
    IO.puts "session: #{inspect session}"
    if (session != nil) do
      conn = conn
        |> assign(:auth_token, session.auth_token)
        |> assign(:id, session.id)
        |> assign(:username, session.username)
        |> assign(:name, session.name)
        |> assign(:account_type, session.account_type)
        |> assign(:profile_image, if(session.profile_image != nil, do: session.profile_image, else: "images/profile/_placeholder.png"))
        |> assign(:dob, session.dob)
        |> assign(:language_code, session.language_code)
        |> assign(:language_template_id, session.language_template_id)
        |> assign(:timezone, session.timezone)
        |> assign(:emails, session.emails)
        |> assign(:phones, session.phones)
        |> assign(:entity_id, session.entity_id)
        |> assign(:entity_profile_image, if(session.entity_profile_image != nil, do: session.entity_profile_image, else: "images/entity/_placeholder.png"))
        |> assign(:client_id, session.client_id)
        |> assign(:client_profile_image, if(session.client_profile_image != nil, do: session.client_profile_image, else: "images/profile-menu.png"))
        |> assign(:xtra_info, session.xtra_info)
        |> assign(:activated_at, session.activated_at)
        |> assign(:created_at, session.created_at)
      {conn, session}
    else
      {conn, :error}
    end
  end
end
