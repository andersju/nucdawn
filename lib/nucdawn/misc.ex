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
    current_year = Date.utc_today.year()
    current_year_ccc_date = Date.from_iso8601!("#{current_year}-12-27")

    case Date.diff(current_year_ccc_date, Date.utc_today)  do
      d when d > 0 -> reply "Next Congress in #{Date.diff(current_year_ccc_date, Date.utc_today)} days!"
      d when d >= -3 -> reply "Congress is happening right now! Grab a Tschunk, #{message.user.nick}!"
      d when d <= -4 ->
        next_year_ccc_date = Date.from_iso8601!("#{current_year+1}-12-27")
        reply "Next Congress in #{Date.diff(next_year_ccc_date, Date.utc_today)} days!"
    end
  end
end
