defmodule CentralGPSWebApp do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(CentralGPSWebApp.Endpoint, []),
      # Here you could define other workers and supervisors as children
      # worker(CentralGPSWebApp.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CentralGPSWebApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def app_config(name) do
    Application.get_env(:app_config, name)
  end

  def rest_client_config(name) do
    Application.get_env(:rest_client, name)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CentralGPSWebApp.Endpoint.config_change(changed, removed)
    :ok
  end
end
