defmodule CentralGPSWebApp.Mixfile do
  use Mix.Project

  def project do
    [app: :central_g_p_s_web_app,
     version: "0.0.2",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps]
  end

  defp package do
      [ contributors: ["cmelgarejo"],
        licenses: ["Licensed Closed Source"],
        links: %{"GitLab" => "https://gitlab.com/CentralGPS/centralgps_webapp"} ]
  end

  def application do
    apps = [:phoenix, :phoenix_html, :cowboy, :logger, :logger_file_backend, :httpoison, :gettext]
    dev_apps = Mix.env == :dev && [ :reprise ] || []
    [ mod: {CentralGPSWebApp, []}, applications: dev_apps ++ apps ]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [{:exrm,                    github: "bitwalker/exrm"},
     {:uuid,                    github: "zyro/elixir-uuid"},
     {:httpoison,               github: "edgurgel/httpoison"},
     {:gettext,                 github: "elixir-lang/gettext"},
     {:reprise, only: :dev,     github: "herenowcoder/reprise"},
     {:logger_file_backend,     github: "onkel-dirtus/logger_file_backend"},
     {:phoenix, override: true, github: "phoenixframework/phoenix"},
     #{:cowboy, override: true,  github: "ninenines/cowboy"},
     {:phoenix_html,            github: "phoenixframework/phoenix_html"},
     {:phoenix_live_reload,     github: "phoenixframework/phoenix_live_reload",
      only: :dev},
     {:cowboy, "~> 1.0"}
    ]
  end

end
