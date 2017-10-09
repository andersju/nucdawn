defmodule Nucdawn.Convert do
  import Kaguya.Module
  import Nucdawn.Helpers

  defh convert(%{"value" => value}) do
    value
    |> parse_input()
    |> parse_regex_result()
    |> convert()
    |> format_response(message)
    |> truncate(400)
    |> reply()
  end

  defp parse_input(input) do
    Regex.named_captures(~r/^(?<from>[\w\s\.\/]+?) (?:to|in|into) (?<to>[\w\s\/]+)/, input)
    |> case do
         nil -> nil
         map -> map
       end
  end

  # FIXME: This is probably vulnerable to atom exhaustion due to the way ExUc works.
  # Possible dirty solution: go through ExUc.Units.all() and create all atoms on startup,
  # then use a few String.to_existing_atom() below?
  defp parse_regex_result(nil), do: nil

  defp parse_regex_result(%{"from" => from, "to" => to}) do
    value = from |> String.trim() |> ExUc.from()

    unit_two =
      if value do
        ExUc.Units.get_key_alias(String.trim(to), value.kind)
      else
        nil
      end

    if value && unit_two do
      {value, unit_two}
    else
      nil
    end
  end

  defp convert(nil), do: nil

  defp convert({value, unit_two}) do
    {value, ExUc.to(value, unit_two)}
  end

  defp format_response(nil, message) do
    "I'm afraid I can't do that, #{message.user.nick}."
  end

  defp format_response({orig, result}, _) do
    orig_value = Float.to_string(orig.value)
    orig_unit = Atom.to_string(orig.unit)
    result_value = Float.to_string(result.value)
    result_unit = Atom.to_string(result.unit)
    "#{orig_value} #{orig_unit} = #{result_value} #{result_unit}"
  end
end
