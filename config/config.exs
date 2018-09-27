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
  karma_tracking: true,
  url_previews: true,
  rate_limit_scale: 5_000, # 5 seconds
  rate_limit_karma_scale: 1_200_000, # 20 minutes
  url_http_headers: ["Accept-Language": "en-US,en;q=0.5"],
  url_whitelist: true,
  url_whitelist_domains: ["imdb.com", "twitter.com", "youtube.com", "vimeo.com", "youtu.be"],
  url_rewrites: %{
    "mobile.twitter.com" => "twitter.com",
  },
  random_channels: [],
  random_strings: ["test", "zzzfoo"],
  country_icons: %{
    "US" => "🦅",
    "CA" => "🏒",
    "FR" => "🥖"
  }

# Add API key to dev.secret.exs and/or prod.secret.exs:
# config :darkskyx,
#   api_key: "your-key-here"
# ...and also API key for Google Geocoding API, preferably:
# config :nucdawn,
#   geocoding_api_key: "your-key-here"
config :darkskyx,
  defaults: [
    units: "auto",
    lang: "en"
  ]

config :geolix,
  databases: [
    %{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      source: "priv/GeoLite2-City.mmdb"
    }
  ]

import_config "#{Mix.env()}.exs"
