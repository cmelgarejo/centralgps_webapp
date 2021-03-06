defmodule CentralGPSWebApp.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use CentralGPSWebApp.Web, :controller
      use CentralGPSWebApp.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """
  def model do
    quote do
      # Define common model functionality
      use Ecto.model
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      # Import URL helpers from the router
      import CentralGPSWebApp.Router.Helpers
      import CentralGPSWebApp.Utilities
      alias CentralGPSWebApp.Endpoint
      alias CentralGPS.Repo.Permissions

    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import URL helpers from the router
      import CentralGPSWebApp.Router.Helpers
      import CentralGPS.L10n
      import CentralGPSWebApp.Utilities
      alias CentralGPS.Repo.Permissions
      alias CentralGPSWebApp.Endpoint

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, #get_flash: 2,
      view_module: 1, action_name: 1, controller_module: 1, router_module: 1 ]

    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
