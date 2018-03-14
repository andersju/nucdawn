defmodule Nucdawn do
  use Kaguya.Module, "Nucdawn"
  import Nucdawn.{Currency, Karma, Misc, URL, Weather, Wikipedia, Xkcd}
  require Logger

  defp karma_tracking, do: Application.get_env(:nucdawn, :karma_tracking)
  defp url_previews, do: Application.get_env(:nucdawn, :url_previews)
  defp rate_limit_scale, do: Application.get_env(:nucdawn, :rate_limit_scale)

  handle "PRIVMSG" do
    enforce :rate_limit do
      match([".w", ".w ~title", "!w", "!w ~title"], :wikipedia, async: true)
      match([".cur :currency", "!cur :currency"], :currency, async: true)

      match(
        [".xkcd", ".xkcd random", ".xkcd ~number", "!xkcd", "!xkcd random", "!xkcd ~number"],
        :xkcd,
        async: true,
        uniq: true
      )

      match([".weather", ".weather ~input", "!weather ~input"], :weather, async: true)

      if karma_tracking() do
        match(["+1 ~subject"], :add_karma, async: true)
        match([".karma", ".karma ~subject"], :show_karma, async: true)
      end

      if url_previews() do
        match_re(~r"https?://[^\s/$.?#].[^\s]*"i, :url, async: true)
      end
    end

    match([".rand :low :high", "!rand :low :high"], :rand, match_group: "[0-9]+")
    match([".ccc", "!ccc"], :ccc)
  end

  defp rate_limit(message) do
    case ExRated.check_rate(message.trailing, rate_limit_scale(), 1) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
