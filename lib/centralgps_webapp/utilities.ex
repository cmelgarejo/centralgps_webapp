defmodule CentralGPSWebApp.Utilities do
  #use Phoenix.View, root: "web/templates"
  # Import convenience functions from controllers
  #import Phoenix.Controller, only: [get_csrf_token: 0]

  def csrf_token_tag do
    # raw """
    # <input type="hidden" name="_csrf_token" value="<%= get_csrf_token  %>">
    # """
  end
end
