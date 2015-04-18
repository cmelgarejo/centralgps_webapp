use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :centralgps_webapp, CentralGPSWebApp.Endpoint,
  secret_key_base: "6HfKSJ0mEtO9klLhq2kU7zDX9bG6XzgSxLqau8xRbLB50dvG2swm4NxhNc6zrAzE"

# Configure your database
config :centralgps_webapp, CentralGPSWebApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "centralgps_webapp_prod"
