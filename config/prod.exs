use Mix.Config

config :kaguya,
  server: "localhost",
  port: 6667,
  bot_name: "nucdawn",
  channels: ["#blargh"],
  help_cmd: ".help",
  use_ssl: false

config :darkskyx,
  api_key: ""

import_config "prod.secret.exs"
