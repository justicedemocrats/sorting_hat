use Mix.Config

config :sorting_hat, SortingHat.Endpoint,
  http: [:inet6, port: {:system, "PORT"}],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :logger, level: :info

config :sorting_hat,
  mongodb_username: "${MONGO_USERNAME}",
  mongodb_seeds: ["${MONGO_SEED_1}", "${MONGO_SEED_2}"],
  mongodb_password: "${MONGO_PASSWORD}",
  mongodb_port: "${MONGO_PORT}"

config :sorting_hat, SortingHat.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: "${MAILGUN_API_KEY}",
  domain: "${MAILGUN_DOMAIN}"

config :ex_twilio,
  account_sid: "${TWILIO_ACCOUNT_SID}",
  auth_token: "${TWILIO_AUTH_TOKEN}"

config :ex_aws,
  access_key_id: "${AWS_ACCESS_KEY_ID}",
  secret_access_key: "${AWS_SECRET_ACCESS_KEY}",
  region: "${AWS_BUCKET_REGION}"

config :sorting_hat, aws_bucket_name: "${AWS_BUCKET_NAME}"
config :sorting_hat, secret: "${SECRET}"
config :sorting_hat, report_complete_webhook: "${REPORT_COMPLETE_WEBHOOK}"
