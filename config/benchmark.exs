import Config

# A mix of prod and dev configs.
# Mainly to get a separate database for benchmarking,
# and to make sure the server is closer to prod performance.
config :short_links, ShortLinks.Repo,
  database: Path.expand("../short_links_benchmark.db", Path.dirname(__ENV__.file)),
  pool_size: 5

config :short_links, ShortLinksWeb.Endpoint,
  server: true,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  secret_key_base: "oiB8wSyawcqtthtqe+BS/x+qGmN3okRUAwuGgdWGV4fqSJcDAZXyQ8xHDQqo46rH"

config :swoosh, :api_client, false

config :logger, level: :info
