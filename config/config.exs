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
  rate_limit_scale: 5_000,
  url_http_headers: ["Accept-Language": "en-US,en;q=0.5"]

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

config :ex_uc,
  #precision: 4,
  allow_exact_results: true
  
config :ex_uc, :length_units,
  fur: ["furlong", "furlongs"],
  pc: ["parsec", "parsecs"],
  ly: ["light-year", "light-years", "light year", "light years"],
  au: ["ua", "astronomical unit", "astronomical units"],
  apc: ["attoparsec", "attoparsecs"]

config :ex_uc, :length_conversions,
  fur_to_yd: 220,
  pc_to_m: 30_857_000_000_000_000,
  ly_to_m: 9_460_700_000_000_000,
  au_to_m: 149_597_870_700,
  apc_to_m: 0.03086

config :ex_uc, :mass_units,
  fir: ["firkin", "firkins"]

config :ex_uc, :mass_conversions,
  fir_to_lb: 90

config :ex_uc, :time_units,
  ftn: ["fortnight", "fortnights"]

config :ex_uc, :time_conversions,
  ftn_to_d: 14

config :ex_uc, :temperature_units,
  C: ["c", "Celsius", "celsius"],
  F: ["f", "Fahrenheit", "fahrenheit"],
  K: ["k", "Kelvin", "kelvin"]

config :ex_uc, :area_units,
  km2: ["square kilometer", "square kilometers", "sqkm"],
  m2: ["square meter", "square meters", "sqm"],
  cm2: ["square centimeter", "square centimeters", "sqcm"],
  mm2: ["square millimeter", "square millimeters", "sqmm"],
  sqmi: ["square mile", "square miles", "mi2"],
  sqyd: ["square yard", "square yards", "yd2"],
  sqft: ["square feet", "square foot", "ft2"],
  sqin: ["square inch", "square inches", "in2"],
  ha: ["hectar", "hectare"],
  ac: ["acre", "acres"],
  fifa_field: ["football field", "football fields"],
  belgium: ["belgiums"]

config :ex_uc, :area_conversions,
  km2_to_m2: 1_000_000,
  m2_to_cm2: 10_000,
  cm2_to_mm2: 100,
  km2_to_sqmi: 0.386102158542,
  sqmi_to_sqyd: 3097600,
  sqyd_to_sqft: 9,
  sqft_to_sqin: 144,
  km2_to_sqft: 10763910.416697,
  km2_to_ha: 100,
  ac_to_m2: 4046.8564224,
  fifa_field_to_m2: 7140,
  belgium_to_km2: 30528

config :geolix,
  databases: [
    %{
      id:      :city,
      adapter: Geolix.Adapter.MMDB2,
      source:  "priv/GeoLite2-City.mmdb"
    }
  ]

import_config "#{Mix.env}.exs"
