# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :nucdawn, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:nucdawn, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

config :nucdawn,
  url_previews: true,
  rate_limit_scale: 5_000

# Add API key to dev.secret.exs and/or prod.secret.exs:
# config :darkskyx,
#   api_key: "your-key-here"
config :darkskyx,
  defaults: [
    units: "auto",
    lang: "en"
  ]

config :ex_uc,
  #precision: 4,
  allow_exact_results: true
  
config :ex_uc, :length_units,
  fur: ["furlong", "furlongs"]

config :ex_uc, :mass_units,
  fir: ["firkin", "firkins"]

config :ex_uc, :time_units,
  ftn: ["fortnight", "fortnights"]

config :ex_uc, :length_conversions,
  fur_to_yd: 220

config :ex_uc, :mass_conversions,
  fir_to_lb: 90

config :ex_uc, :time_conversions,
  ftn_to_d: 14

import_config "#{Mix.env}.exs"
