defmodule Nucdawn.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nucdawn,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:kaguya, "~> 0.6"},
      {:kaguya, git: "https://github.com/Luminarys/Kaguya.git", ref: "e82d25f"},
      {:httpoison, "~> 0.13"},
      {:floki, "~> 0.18.0"},
      {:poison, "~> 3.1", override: true},
      {:coinmarketcap_api, "~> 1.2"},
      {:xkcd, "~> 0.0.1"},
      {:darkskyx, "~> 0.1.1"},
      {:ex_rated, "~> 1.2"},
      {:public_suffix, "~> 0.5"},
      {:idna, "~> 5.0", override: true},
      {:geolix, "~> 0.15"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end
end
