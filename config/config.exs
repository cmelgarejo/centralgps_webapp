# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :central_g_p_s_web_app, CentralGPSWebApp.Endpoint,
  url: [host: "checkpoint.centralgps.net"],
  secret_key_base: "4lRqXzOIYxiVuta7PzAy6YcXsb6PyJItgIlZ6lvycAmlWQQ4HVf2X5IVWFKUqk/W",
  debug_errors: false,
  pubsub: [name: CentralGPSWebApp.PubSub, adapter: Phoenix.PubSub.PG2]

config :app_config, entity_tag: "edge"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :rest_client,
  rest_client_base_url: "https://api.centralgps.net/api/v1",
  #rest_client_base_url: "http://localhost:4000/api/v1",
  rest_client_app_name: "centralgps_webapp"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
