use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :central_g_p_s_web_app, CentralGPSWebApp.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  watchers: []

# Watch static and templates for browser reloading.
config :central_g_p_s_web_app, CentralGPSWebApp.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|eot|svg|ttf|woff|woff2)$},
      #~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
