defmodule CentralGPSWebApp.LayoutView do
  use CentralGPSWebApp.Web, :view
  def handler_info(conn) do
    "Request Handled By: #{controller_module conn}::#{action_name conn}"
  end
end
