defmodule Nucdawn.Weather do
  # Ideas borrowed from https://github.com/ryanwinchester/hedwig_weather
  import Kaguya.Module
  import Nucdawn.Helpers
  import Nucdawn.Misc

  defp api_key, do: Application.get_env(:nucdawn, :geocoding_api_key)
  defp country_icons, do: Application.get_env(:nucdawn, :country_icons)

  defmodule Weather do
    defstruct [
      :text,
      :country,
      :symbol,
      :temperature,
      :windspeed,
      :humidity,
      :currently,
      :hourly,
      :daily,
      :units
    ]
  end

  defh weather do
    {place, units} = get_place_and_units(message)

    place
    |> fetch_coordinates()
    |> handle_coordinates()
    |> fetch_weather(units)
    |> handle_weather()
    |> format_weather()
    |> truncate(400)
    |> reply()
  end

  defp get_place_and_units(message) do
    if message.trailing == ".weather" do
      geoinfo =
        message.user.host
        |> get_ip_by_host()
        |> get_geolocation_by_ip()

      place =
        case geoinfo.city do
          nil -> geoinfo.country.name
          _ -> geoinfo.city.name <> ", " <> geoinfo.country.name
        end
      {place, "auto"}
    else
      %{"place" => place, "units" => units} =
        Regex.named_captures(~r/^.weather ((?<units>si|us)\s)?(?<place>.*)/, message.trailing)

      units = if units == "", do: "auto", else: units

      {place, units}
    end
  end

  defp fetch_coordinates(place) do
    HTTPoison.get(
      "https://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=#{URI.encode(place)}&key=#{
        api_key()
      }"
    )
  end

  defp handle_coordinates({:ok, %{status_code: 200, body: body}}) do
    result =
      body
      |> Poison.decode!()
      |> get_in(["results"])
      |> List.first()

    country =
      result["address_components"]
      |> Enum.filter(fn x -> Enum.member?(Map.get(x, "types", []), "country") end)
      |> List.first
      |> case do
           result when is_map(result) -> Map.get(result, "short_name", nil)
           nil -> nil
         end

    %{
      "lat" => result["geometry"]["location"]["lat"],
      "lng" => result["geometry"]["location"]["lng"],
      "text" => result["formatted_address"],
      "country" => country
    }
  end

  defp handle_coordinates(nil), do: nil

  defp fetch_weather(nil, _units), do: nil
  defp fetch_weather(%{"lat" => nil}, _units), do: nil

  defp fetch_weather(%{"lat" => lat, "lng" => lng, "text" => text, "country" => country}, units) do
    {Darkskyx.forecast(lat, lng, %Darkskyx{units: units}), text, country}
  end

  defp handle_weather({{:ok, weather}, text, country}) do
    %Weather{
      text: text,
      country: country,
      symbol: get_symbol(weather["currently"]["icon"]),
      temperature: weather["currently"]["temperature"],
      windspeed: weather["currently"]["windSpeed"],
      humidity: round(weather["currently"]["humidity"] * 100),
      currently: weather["currently"]["summary"],
      hourly: weather["hourly"]["summary"],
      daily: weather["daily"]["summary"],
      units: weather["flags"]["units"]
    }
  end

  defp handle_weather({_, _}), do: nil

  defp format_weather(%Weather{} = weather) do
    temp_unit = get_temp_unit(weather.units)
    wind_unit = get_wind_unit(weather.units)
    temperature = show_c_and_f(weather.temperature, temp_unit)
    country_icon = get_country_icon(weather.country)

    "#{weather.text}#{country_icon}: #{weather.symbol} #{temperature}. " <>
      "Humidity: #{weather.humidity}%. Wind: #{weather.windspeed} #{wind_unit}. " <>
      "#{weather.hourly} #{weather.daily}"
  end

  defp format_weather(nil), do: "Sorry. I failed. :("

  defp get_country_icon(code) do
    icon = Map.get(country_icons(), code, nil)
    if icon, do: " #{icon}", else: ""
  end

  defp get_symbol(icon) do
    cond do
      String.contains?(icon, "clear") -> "☀"
      String.contains?(icon, "partly-cloudy") -> "⛅"
      String.contains?(icon, "cloudy") -> ""
      String.contains?(icon, "rain") || String.contains?(icon, "sleet") -> "🌧"
      String.contains?(icon, "tstorms") -> ""
      String.contains?(icon, "fog") -> ""
      String.contains?(icon, "snow") -> ""
      String.contains?(icon, "wind") -> "🍃"
      true -> ""
    end
  end

  defp show_c_and_f(temperature, "°C") do
    "#{round(temperature)}°C (#{round(temperature * (9 / 5) + 32)}°F)"
  end

  defp show_c_and_f(temperature, "°F") do
    "#{round(temperature)}°F (#{round((temperature - 32) / (9 / 5))}°C)"
  end

  defp get_temp_unit(n) when n in ["si", "ca", "uk2"], do: "°C"
  defp get_temp_unit("us"), do: "°F"
  defp get_temp_unit(_), do: ""

  defp get_wind_unit("si"), do: "m/s"
  defp get_wind_unit("us"), do: "mph"
  defp get_wind_unit("ca"), do: "km/h"
  defp get_wind_unit("uk2"), do: "mph"
  defp get_wind_unit(_), do: ""
end
