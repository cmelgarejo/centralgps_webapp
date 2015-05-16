defmodule CentralGPSWebApp.Mixfile do
  use Mix.Project

  def project do
    [app: :central_g_p_s_web_app,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps]
  end

  defp package do
      [ contributors: ["cmelgarejo, gabik077"],
        licenses: ["Licensed Closed Source"],
        links: %{"GitLab" => "https://gitlab.com/CentralGPS/centralgps_webapp"} ]
  end

  def application do
    apps = [:phoenix, :phoenix_html, :cowboy, :logger, :logger_file_backend, :httpoison ]
    dev_apps = Mix.env == :dev && [ :reprise ] || []
    [ mod: {CentralGPSWebApp, []}, applications: dev_apps ++ apps ]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [{:exrm,                github: "bitwalker/exrm"},
     {:reprise,             github: "herenowcoder/reprise", only: :dev},
     {:httpoison,           github: "edgurgel/httpoison"},
     {:logger_file_backend, github: "onkel-dirtus/logger_file_backend"},
     {:cowboy, "~> 1.0"},
     {:phoenix, "~> 0.13"},
     {:phoenix_html, "~> 1.0"},
     {:phoenix_live_reload, "~> 0.4", only: :dev}]
  end

end
