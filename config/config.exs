# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :hellow, Hellow.Endpoint,
  url: [host: "schleumer-phoenix.us-west-2.elasticbeanstalk.com", host: "localhost"],
  check_origin: false,
  secret_key_base: "DzrOIUxmqRLni/4GbEL+YGMWJvrEKBzGpHrF52dJtAESdRXJGKK6jXx0o/2e+Zrg",
  render_errors: [view: Hellow.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Hellow.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :hellow, Hellow.WebsocketEndpoint,
  url: [host: "schleumer-phoenix.us-west-2.elasticbeanstalk.com", port: 8181],
  check_origin: false,
  secret_key_base: "DzrOIUxmqRLni/4GbEL+YGMWJvrEKBzGpHrF52dJtAESdRXJGKK6jXx0o/2e+Zrg",
  pubsub: [name: Hellow.WebsocketPubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
