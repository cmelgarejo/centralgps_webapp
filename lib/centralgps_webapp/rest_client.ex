defmodule CentralGPS.RestClient do
  use HTTPoison.Base
  import CentralGPS.Repo.Utilities

  defp ct_json_header, do: [{"Content-Type", "application/json;charset=utf-8"}]
  defp auth_header(token, type), do: [ {"Authorization", "CentralGPS token=#{token},type=#{type}"} ]
  defp security_login_path(type), do: "/security/login/" <> type
  defp security_logout_path(type), do: "/security/logout/" <> type

  def login_api_post_json(type, data, headers \\ []) do
    post security_login_path(type), data, (headers ++ ct_json_header)
  end

  def logout_api_post_json(token, type, data \\ "", headers \\ []) do
    post security_logout_path(type), data,
      (headers ++ ct_json_header ++ auth_header(token, type))
  end

  def api_post_json(method_path, token, type, data, headers \\ []) do
    post method_path, data, headers ++ ct_json_header ++ auth_header(token, type)
  end

  def api_get_json(method_path, token, type, headers \\ []) do
    get method_path, (headers ++ auth_header(token, type))
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
