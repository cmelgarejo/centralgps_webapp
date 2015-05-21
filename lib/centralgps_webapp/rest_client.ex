defmodule CentralGPS.RestClient do
  use HTTPoison.Base
  import CentralGPS.Repo.Utilities

  def login_api_post_json(method_path, type, data, headers \\ []) do
    method_path = method_path <> "/" <> type
    headers
    || [ {"Content-Type", "application/json;charset=utf-8"} ]
    post method_path, data, headers
  end

  def api_post_json(method_path, token, type, data, headers \\ []) do
    headers
    || [ {"Content-Type", "application/json;charset=utf-8"} ]
    || [ {"Content-Type", "CentralGPS token=#{token},type=#{type}"} ]
    post method_path, data, headers
  end

  def api_get_json(method_path, token, type, headers) do
    headers
    || [ {"Content-Type", "CentralGPS token=#{token},type=#{type}"} ]
    get method_path, headers
  end

  def process_url(method_path) do
    CentralGPSWebApp.rest_client_config(:rest_client_base_url) <> method_path
  end

  def process_response_body(body) do
    try do
      body
        |> Poison.decode!
        |> objectify_map
    rescue
      _ in _ ->
        #error_logger e, __ENV__, [ body ]
        body
    end
  end
end
