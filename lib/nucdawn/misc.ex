defmodule Nucdawn.Misc do
  import Kaguya.Module
  import Nucdawn.Helpers

  defh rand(%{"low" => low, "high" => high}) do
    String.to_integer(low)..String.to_integer(high)
    |> Enum.random()
    |> truncate(400)
    |> reply
  end

  defh ccc do
    current_year = Date.utc_today().year
    current_year_ccc_date = Date.from_iso8601!("#{current_year}-12-27")

    case Date.diff(current_year_ccc_date, Date.utc_today()) do
      d when d == 1 ->
        reply("Next Congress in #{Date.diff(current_year_ccc_date, Date.utc_today())} day!")
      d when d > 0 ->
        reply("Next Congress in #{Date.diff(current_year_ccc_date, Date.utc_today())} days!")

      d when d >= -3 ->
        reply("Congress is happening right now! Grab a Tschunk, #{message.user.nick}!")

      d when d <= -4 ->
        next_year_ccc_date = Date.from_iso8601!("#{current_year + 1}-12-27")
        reply("Next Congress in #{Date.diff(next_year_ccc_date, Date.utc_today())} days!")
    end
  end

  def get_geolocation_by_ip(ip) do
    ip
    |> Geolix.lookup(where: :city, locale: :en)
  end

  def get_ip_by_host(host) do
    host
    |> String.to_charlist()
    |> :inet.gethostbyname()
    |> case do
      # Probably IPv6 address. Very ugly workaround. FIXME
      {:error, _} ->
        host

      {:ok, hostent} ->
        hostent |> elem(5) |> hd |> Tuple.to_list() |> Enum.join(".")
    end
  end
end
