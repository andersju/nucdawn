use Mix.Config

config :kaguya,
  server: "localhost",
  port: 6667,
  bot_name: "nucdawn",
  channels: ["#blargh", "#blurgh"],
  help_cmd: ".help",
  use_ssl: false

import_config "dev.secret.exs"
