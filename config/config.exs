# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :sorting_hat, SortingHat.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OJWZyqjz+N8e9pOS1a2CkiYej0tg92moAbMQ6RdQFi4pUT0u9LI3zkR0ZwGWDaOL",
  render_errors: [view: SortingHat.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SortingHat.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mnesia, dir: 'mnesia/#{Mix.env()}/#{node()}'

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
