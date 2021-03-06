defmodule CentralGPSWebApp.Client.Checkpoint.RoadmapPointVenueFormController do
  use CentralGPSWebApp.Web, :controller
  import CentralGPS.RestClient
  import CentralGPS.Repo.Utilities

  # POST    /api/v1/checkpoint/roadmap_point_venue
  # DELETE  /api/v1/checkpoint/roadmap_point_venue

  def save(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, save_record(session, params)
    end
  end

  def delete(conn, params) do
    {conn, session} = centralgps_session conn
    if(session == :error) do
      redirect conn, to: login_path(Endpoint, :index)
    else #do your stuff and render the page.
      json conn, delete_record(session, params)
    end
  end

  #private functions
  defp api_method(roadmap_point_id \\ "") when is_bitstring(roadmap_point_id),
    do: "/checkpoint/roadmap_point_venue_form/" <> roadmap_point_id

  defp delete_record(s, p) do
    p = objectify_map p
      |> Map.update(:roadmap_point_id,  nil, &(parse_int(&1)))
    {api_status, res} =
      api_delete_json api_method(p.roadmap_point_id), s.auth_token, s.account_type
    if(api_status == :ok) do
      if !res.body.status, do: res = Map.put res, :body, %{ status: false, msg: res.body.msg }
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    res.body
  end

  defp save_record(s, p) do
    p = objectify_map p
      |> Map.update(:roadmap_point_id,  nil, &(parse_int(&1)))
      |> Map.update(:venue_id,          nil, &(parse_int(&1)))
      |> Map.update(:form_id,         nil, &(parse_int(&1)))
    data = %{ roadmap_point_id: p.roadmap_point_id, venue_id: p.venue_id, form_id: p.form_id }
    {api_status, res} = api_post_json api_method, s.auth_token, s.account_type, data
    if(api_status == :ok) do
      if !res.body.status, do: res = Map.put res, :body, %{ status: false, msg: res.body.msg }
    else
      res = Map.put res, :body, %{ status: false, msg: res.reason }
    end
    res.body
  end
end
