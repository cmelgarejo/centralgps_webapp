defmodule CentralGPS.RestClient do
  use HTTPoison.Base
  import CentralGPS.Repo.Utilities

  def process_url(method_path) do
    CentralGPSWebApp.rest_client_config(:rest_client_base_url) <> method_path
  end

  def process_response_body(body) do
    try do
      body
        |> Poison.decode!
        |> objectify_map
    rescue
      e in _ ->
        #error_logger e, __ENV__, [ body ]
        body
    end
  end
end
