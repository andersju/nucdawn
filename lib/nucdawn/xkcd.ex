defmodule Nucdawn.Xkcd do
  import Kaguya.Module
  import Nucdawn.Helpers

  defh xkcd do
    message.trailing
    |> check_input()
    |> get_xkcd()
    |> format_xkcd()
    |> truncate(400)
    |> reply()
  end

  defp check_input(input) do
    case Regex.run(~r/.xkcd\s?([a-z0-9]+)/, input, capture: :all_but_first) do
      nil -> nil
      n -> List.first(n)
    end
  end

  defp get_xkcd(nil), do: Xkcd.random()
  defp get_xkcd("random"), do: Xkcd.random()
  defp get_xkcd("latest"), do: Xkcd.latest()
  defp get_xkcd(number), do: Xkcd.number(String.to_integer(number))

  defp format_xkcd({:error, msg}), do: "Sorry: #{msg}."
  defp format_xkcd({:ok, %Xkcd.Comic{} = comic}) do
    "https://xkcd.com/#{comic.num} | #{comic.title} | Alt: #{comic.alt}"
  end
end
