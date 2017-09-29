defmodule Nucdawn.Wikipedia do
  import Kaguya.Module
  import Nucdawn.Helpers

  defh wikipedia do
    message.trailing
    |> get_wikipedia_snippet()
    |> format_wikipedia_snippet(true)
    |> truncate(400)
    |> reply()
  end

  def get_wikipedia_snippet(title, lang \\ "en") do
    url = get_wikipedia_url(title, lang)

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        body
        |> Poison.decode!
        |> get_in(["query", "pages"])
        |> Map.to_list
        |> List.first
        |> elem(1)
        |> Map.take(["title", "extract"])
        |> Map.put("lang", lang)
      _ -> nil
    end
  end

  defp get_wikipedia_url(title, lang) do
    title
    |> String.replace(~r"^(\.|!)w\s?", "")
    |> case do
         "" -> "https://#{lang}.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&exchars=300&redirects&grnnamespace=0&generator=random"
         title -> "https://#{lang}.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&exchars=300&redirects&titles=#{URI.encode(title)}"
       end
  end

  def format_wikipedia_snippet(%{"extract" => extract, "title" => title, "lang" => lang}, show_url) do
    title_query = title |> String.replace(" ", "_") |> truncate(100)
    extract_stripped = extract |> String.replace("\n", " ") |> truncate(300)
    if show_url do
      "[WIKIPEDIA] #{title} | #{extract_stripped} | https://#{lang}.wikipedia.org/wiki/#{title_query}"
    else
      "[WIKIPEDIA] #{title} | #{extract_stripped}"
    end
  end
  def format_wikipedia_snippet(_, _), do: "Sorry."

end
