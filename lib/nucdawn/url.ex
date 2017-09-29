defmodule Nucdawn.URL do
  import Kaguya.Module
  import Nucdawn.Wikipedia
  import Nucdawn.Helpers

  defh url(%{trailing: input}) do
    Regex.run(~r"https?://[^\s/$.?#].[^\s]*"i, input)
    |> List.first()
    |> handle_url()
    |> truncate(400)
    |> case do
         nil -> nil
         text -> reply(text)
       end
  end

  defp handle_url(url) do
    # Let the Wikipedia module handle wikipedia.org URLs
    case Regex.named_captures(~r"(?<lang>[a-z]+).(wikipedia.org/wiki/)(?<title>[^ ]+)", url) do
      %{"title" => title, "lang" => lang} ->
        title
        |> get_wikipedia_snippet(lang)
        |> format_wikipedia_snippet(false)
      nil ->
        url
        |> validate_url()
        |> get_url_info()
        |> format_url_info(url)
    end
  end

  defp validate_url(url) do
    url
    |> URI.parse()
    |> Map.get(:host)
    |> PublicSuffix.matches_explicit_rule?()
    |> case do
         true -> url
         false -> nil
       end
  end

  defp get_url_info(nil), do: nil
  defp get_url_info(url) do
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        body
        |> Floki.find("title")
        |> Floki.text()
        |> String.replace("\r", "")
        |> String.replace("\n", "")
        |> String.trim()
        |> truncate(200) # Protection against horribly broken sites
      _ ->
        nil
    end
  end

  defp format_url_info("", _url), do: nil
  defp format_url_info(nil, _url), do: nil
  defp format_url_info(title, url), do: "[ #{title} ] - #{URI.parse(url).host}"
end
