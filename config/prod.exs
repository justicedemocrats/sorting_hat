use Mix.Config

config :sorting_hat, SortingHat.Endpoint,
  http: [:inet6, port: {:system, "PORT"}],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :logger, level: :info

config :sorting_hat,
  mongodb_username: "${MONGO_USERNAME}",
  mongodb_hostname: "${MONGO_HOSTNAME}",
  mongodb_password: "${MONGO_PASSWORD}",
  mongodb_port: "${MONGO_PORT}"

config :sorting_hat, SortingHat.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: "${MAILGUN_API_KEY}",
  domain: "${MAILGUN_DOMAIN}"
