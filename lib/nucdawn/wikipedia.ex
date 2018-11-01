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
    {random, url} = get_wikipedia_url(title, lang)

    case random do
      true -> get_wikipedia_random(url, lang)
      false -> get_wikipedia_search(url, lang)
    end
  end

  defp get_wikipedia_random(url, lang) do
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        body
        |> Poison.decode!()
        |> get_in(["query", "pages"])
        |> Map.to_list()
        |> List.first()
        |> elem(1)
        |> Map.take(["title", "extract"])
        |> Map.put("lang", lang)
      _ ->
        nil
    end
  end

  # TODO: Make less messy
  defp get_wikipedia_search(url, lang) do
    json =
     case HTTPoison.get(url) do
       {:ok, %{status_code: 200, body: body}} ->
         body
         |> Poison.decode!()
       _ ->
        nil
     end

    if json do
      if json["query"]["searchinfo"]["totalhits"] > 0 do
        result = json |> get_in(["query", "search"]) |> List.first()
        %{"snippet" => snippet, "title" => title} = result
        %{"extract" => snippet <> "...", "title" => title, "lang" => lang}
      else
        if json["query"]["searchinfo"]["suggestion"] do
          get_wikipedia_snippet(json["query"]["searchinfo"]["suggestion"])
        else
          nil
        end
      end
    else
      nil
    end
  end

  defp get_wikipedia_url(title, lang) do
    title
    |> String.replace(~r"^(\.|!)w\s?", "")
    |> case do
      "" ->
        {true, "https://#{lang}.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&exchars=300&redirects&grnnamespace=0&generator=random"}

      title ->
        {false, "https://#{lang}.wikipedia.org/w/api.php?format=json&action=query&list=search&srsearch=#{
          URI.encode(title)}"}
    end
  end

  def format_wikipedia_snippet(%{"extract" => extract, "title" => title, "lang" => lang}, show_url) do
    title_query = title |> String.replace(" ", "_") |> truncate(100)
    extract_stripped = extract |> String.replace("\n", " ") |> HtmlSanitizeEx.strip_tags() |> truncate(300)

    if show_url do
      "[WIKIPEDIA] #{title} | #{extract_stripped} | https://#{lang}.wikipedia.org/wiki/#{
        title_query
      }"
    else
      "[WIKIPEDIA] #{title} | #{extract_stripped}"
    end
  end

  def format_wikipedia_snippet(_, _), do: raise "Oops."
end
