defmodule Nucdawn.URL do
  import Kaguya.Module
  import Nucdawn.Wikipedia
  import Nucdawn.Helpers

  defp url_http_headers, do: Application.get_env(:nucdawn, :url_http_headers)

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
        |> check_location_and_type()
        |> get_url_info()
        |> format_url_info()
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

  defp check_location_and_type(nil), do: nil

  defp check_location_and_type(url) do
    case :hackney.request("head", url, url_http_headers(), <<>>, follow_redirect: true) do
      {:ok, {:maybe_redirect, _, headers, _}} ->
        case is_html?(headers) do
          true -> :hackney.redirect_location(headers)
          false -> nil
        end

      {:ok, 200, headers} ->
        case is_html?(headers) do
          true -> url
          false -> nil
        end

      _ ->
        nil
    end
  end

  defp is_html?(headers) do
    Enum.any?(headers, fn {name, value} ->
      String.contains?(String.downcase(name), "content-type") &&
        String.contains?(String.downcase(value), "text/html")
    end)
  end

  defp get_url_info(nil), do: nil

  defp get_url_info(url) do
    case HTTPoison.get(url, url_http_headers()) do
      {:ok, %{status_code: 200, body: body}} ->
        {truncate(get_title(body), 120), truncate(get_description(body), 280)}

      _ ->
        nil
    end
  end

  defp get_title(body) do
    body
    |> Floki.find("title")
    |> Enum.reject(fn x -> x |> Tuple.to_list() |> List.flatten() |> Enum.count() > 2 end)
    |> get_clean_text()
  end

  defp get_description(body) do
    body
    |> Floki.find("meta[name=description]")
    |> Floki.attribute("content")
    |> get_clean_text()
  end

  defp get_clean_text(list) do
    list
    |> Floki.text()
    |> String.replace("\r", "")
    |> String.replace("\n", "")
    |> String.trim()
  end

  defp format_url_info(""), do: nil
  defp format_url_info(nil), do: nil
  defp format_url_info({title, ""}), do: "#{title}"
  defp format_url_info({title, description}), do: "#{title} | #{description}"
end
