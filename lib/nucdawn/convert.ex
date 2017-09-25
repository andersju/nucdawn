defmodule Nucdawn.Convert do
  import Kaguya.Module
  import Nucdawn.Helpers

  defh convert(%{"value" => value}) do
    value
    |> ExUc.from()
    |> get_unit_from_alias()
    |> choose_conversion()
    |> convert_value(value)
    |> format_value()
    |> format_response(value, message)
    |> truncate(400)
    |> reply()
  end

  defp get_unit_from_alias(nil), do: nil
  defp get_unit_from_alias(%{kind: kind, unit: unit}) do
    # This avoids having to check aliases in choose_conversion() below.
    # See ExUc.Units.all for possible aliases.
    ExUc.Units.get_key_alias(unit, kind)
  end

  defp choose_conversion(nil), do: nil
  defp choose_conversion(value) when is_atom(value) do
    case value do
      # Length
      :mm -> [:in]
      :cm -> [:ft_in]
      :m -> [:ft_in, :yd]
      :km -> [:mi]
      :in -> [:mm, :cm]
      :ft -> [:m]
      :yd -> [:m]
      :mi -> [:km]
      :fur -> [:yd, :m]
      :au -> [:m, :km, :ft, :mi, :ly, :pc]
      :ly -> [:m, :km, :ft, :mi, :au, :pc]
      :pc -> [:m, :km, :ft, :mi, :au, :ly]
      :atpc -> [:cm, :m, :in, :ft]
      # Mass
      :mg -> [:oz]
      :g -> [:lb_oz]
      :kg -> [:lb_oz]
      :oz -> [:g]
      :lb -> [:kg]
      :fir -> [:lb, :kg]
      # Time
      :μs -> [:ms, :s]
      :ms -> [:μs, :s]
      :s  -> [:ms, :min]
      :min -> [:min, :h]
      :h -> [:min, :d]
      :d -> [:h]
      :ftn -> [:d]
      # Temperature
      :C -> [:F, :K]
      :F -> [:C, :K]
      :K -> [:C, :F]
      # Speed
      :mps -> [:"km/h", :mph, :kn]
      :kmph -> [:"m/s", :mph, :kn]
      :miph -> [:"m/s", :"km/h", :kn]
      :kn -> [:"m/s", :"km/h", :mph]
      # Pressure
      :Pa -> [:hPa, :kPa, :bar, :at, :atm, :mmHg, :psi]
      :hPa -> [:Pa, :kPa, :bar, :at, :atm, :mmHg, :psi]
      :kPa -> [:Pa, :hPa, :bar, :at, :atm, :mmHg, :psi]
      :bar -> [:Pa, :hPa, :kPa, :at, :atm, :mmHg, :psi]
      :at -> [:Pa, :hPa, :kPa, :bar, :atm, :mmHg, :psi]
      :atm -> [:Pa, :hPa, :kPa, :bar, :at, :mmHg, :psi]
      :mmHg -> [:Pa, :hPa, :kPa, :bar, :at, :atm, :psi]
      :psi -> [:Pa, :hPa, :kPa, :bar, :at, :atm, :mmHg, :psi]
      # Memory. Add PB and above?
      :B -> [:b, :KiB, :KB, :MiB, :MB, :GiB, :GB, :TiB, :TB]
      :KB -> [:B, :KiB, :MiB, :MB, :GiB, :GB, :TiB, :TB]
      :MB -> [:B, :KiB, :KB, :MiB, :GiB, :GB, :TiB, :TB]
      :GB -> [:B, :KiB, :KB, :MiB, :MB, :GiB, :TiB, :TB]
      :TB -> [:B, :KiB, :KB, :MiB, :MB, :GiB, :GB, :TiB]
      :KiB -> [:B, :KB, :MiB, :MB, :GiB, :GB, :TiB, :TB]
      :MiB -> [:B, :KiB, :KB, :MB, :GiB, :GB, :TiB, :TB]
      :GiB -> [:B, :KiB, :KB, :MiB, :MB, :GiB, :GB, :TiB, :TB]
      :TiB -> [:B, :KiB, :KB, :MiB, :MB, :GiB, :GB, :TB]
      :b -> [:Kb, :Mb, :Gb, :B, :KB, :MB]
      :Kb -> [:b, :Mb, :Gb, :B, :KB, :MB]
      :Mb -> [:b, :Kb, :Gb, :B, :KB, :MB, :GB]
      :Gb -> [:b, :Kb, :Mb, :Tb, :B, :KB, :MB, :GB, :TB]
      :Tb -> [:b, :Kb, :Mb, :B, :KB, :MB, :GB, :TB]
      # Area
      :km2 -> [:m2, :sqmi, :ha, :ac, :fifa_field, :belgium]
      :m2 -> [:sqft, :km2, :fifa_field]
      :cm2 -> [:mm2, :m2]
      :mm2 -> [:cm2, :sqin]
      :sqmi -> [:m2, :km2, :fifa_field, :belgium]
      :sqyd -> [:sqft, :sqmi, :m2, :km2]
      :sqft -> [:m2, :km2, :sqmi]
      :sqin -> [:sqft, :mm2, :cm2]
      :ha -> [:ac, :km2, :sqmi, :fifa_field]
      :ac -> [:ha, :km2, :sqmi, :fifa_field]
      :fifa_field -> [:m2, :km2, :sqmi]
      :belgium -> [:km2, :sqmi, :fifa_field]
      _ -> nil
    end
  end

  defp convert_value(nil, _), do: nil
  defp convert_value(units, value) when is_list(units) do
    Enum.map(units, fn(x) -> ExUc.to(value, x) end)
  end

  defp format_value(nil), do: nil
  defp format_value(converted) when is_list(converted) do
    converted
    |> Enum.map(&ExUc.as_string/1)
    |> Enum.join(" | ")
  end

  defp format_response(nil, _, message) do
    "I'm afraid I can't do that, #{message.user.nick}."
  end
  defp format_response(converted, value, _) do
    value <> " = " <> converted
  end
end
