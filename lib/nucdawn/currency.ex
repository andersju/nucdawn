 defmodule Nucdawn.Currency do
  import Kaguya.Module
  import Nucdawn.Helpers

  defh currency(%{"currency" => currency}) do
    currency
    |> parse_currency()
    |> fetch_currency_ticker()
    |> format_currency_ticker()
    |> truncate(400)
    |> reply()
  end

  defp parse_currency(text) do
    case text do
      n when n in ["btc", "bitcoin"] -> "bitcoin"
      n when n in ["bch", "bitcoincash"] -> "bitcoin-cash"
      n when n in ["eth", "ethereum"] -> "ethereum"
      n when n in ["xmr", "monero"] -> "monero"
      _ -> nil
    end
  end

  defp fetch_currency_ticker(nil), do: nil
  defp fetch_currency_ticker(coin) do
    case HTTPoison.get("https://api.coinmarketcap.com/v1/ticker/#{coin}/?convert=EUR") do
      {:ok, %{status_code: 200, body: body}} ->
        body
        |> Poison.decode!
        |> List.first()
      _ -> nil
    end
  end

  defp format_currency_ticker(nil), do: "I'm afraid I couldn't do that, Dave."
  defp format_currency_ticker(data) do
    time =
      data["last_updated"]
      |> String.to_integer
      |> DateTime.from_unix!
      |> DateTime.to_string

    "#{data["name"]} (#{data["symbol"]}): #{data["price_usd"]} USD / #{data["price_eur"] |> String.to_float |> Float.round(2)} EUR. 1h/24h/7d: #{data["percent_change_1h"]}% #{data["percent_change_24h"]}% #{data["percent_change_7d"]}%. Last updated #{time}." 
  end
end
