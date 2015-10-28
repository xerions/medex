use Mix.Config

config :medex, ip: "127.0.0.1"
config :medex, port: 4000

# use consul, no by default
config :medex, consul: false

# which service name will be using for consul health-checks
#config :medex, service_id: "service_example"
