defmodule CentralGPSWebApp.Mixfile do
  use Mix.Project

  def project do
    [app: :central_g_p_s_web_app,
     version: "0.0.5",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps]
  end

  defp package do
      [ contributors: ["cmelgarejo"],
        licenses: ["Licensed Private Source"],
        links: %{"GitLab" => "https://gitlab.com/CentralGPS/centralgps_webapp"} ]
  end

  def application do
    apps = [ :cowboy, :gettext, :httpoison, :logger, :logger_file_backend, :phoenix, :phoenix_html, :uuid]
    dev_apps = Mix.env == :dev && [ :reprise, :phoenix_live_reload ] || []
    [ mod: {CentralGPSWebApp, []}, applications: dev_apps ++ apps ]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [
      #{:cowboy,              github: "ninenines/cowboy", override: true}
      {:cowboy,               "~> 1.0"},
      {:exrm,                 github: "bitwalker/exrm"},
      {:gettext,              github: "elixir-lang/gettext"},
      {:httpoison,            github: "edgurgel/httpoison"},
      {:logger_file_backend,  github: "onkel-dirtus/logger_file_backend"},
      {:reprise,              github: "herenowcoder/reprise", only: :dev},
      {:phoenix,              github: "phoenixframework/phoenix", override: true},
      {:phoenix_live_reload,  github: "phoenixframework/phoenix_live_reload", only: :dev},
      {:phoenix_html,         github: "phoenixframework/phoenix_html", override: true},
      {:uuid,                 github: "zyro/elixir-uuid"}
    ]
  end

end
