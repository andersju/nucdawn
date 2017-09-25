defmodule Nucdawn do
  use Kaguya.Module, "Nucdawn"
  import Nucdawn.{Convert, Currency, Misc, URL, Weather, Wikipedia, Xkcd}
  require Logger

  defp url_previews, do: Application.get_env(:nucdawn, :url_previews)
  defp rate_limit_scale, do: Application.get_env(:nucdawn, :rate_limit_scale)

  handle "PRIVMSG" do
    enforce :rate_limit do
      match [".w", ".w ~title"], :wikipedia, async: true
      match ".cur :currency", :currency, async: true
      match [".xkcd", ".xkcd random", ".xkcd ~number"], :xkcd, async: true, uniq: true
      match [".weather ~input"], :weather, async: true
      if url_previews() do
        match_re ~r"https?://[^\s/$.?#].[^\s]*"i, :url, async: true
      end
    end
    match ".rand :low :high", :rand, match_group: "[0-9]+"
    match ".convert ~value", :convert
  end

  defp rate_limit(message) do
    case ExRated.check_rate(message.trailing, rate_limit_scale(), 1) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
