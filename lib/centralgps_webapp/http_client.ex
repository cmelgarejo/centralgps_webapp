defmodule CentralGPSWebApp.HttpClient do
  use HTTPoison.Base
  import CentralGPSWebApp
  #import CentralGPS.Repo.Utilities
  #defp process_request_headers(headers), do: headers

  def process_url(method_path) do
    http_client_config(:http_client_base_url) <> method_path
  end

  # defp process_status_code(status_code), do: status_code
  #
  # def process_response_body(body) do
  #   try do
  #     case status_code do
  #       x when x > 200 and x < 300 ->
  #         body
  #           |> Poison.decode!
  #           |> (Enum.map(fn({k, v}) -> {String.to_atom(k), v} end))
  #       x when (x > 300 and x < 600) ->
  #         %{status: false, msg: body}
  #     end
  #   rescue
  #     e in _ ->
  #       error_logger e, __ENV__, [ body ]
  #       body
  #   end
  # end
end
