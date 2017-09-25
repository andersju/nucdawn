defmodule Nucdawn.Helpers do
  def truncate(string, maximum) when is_binary(string) do
    case String.length(string) > maximum do
      true -> "#{String.slice(string, 0, maximum)}..."
      false -> string
    end
  end
  def truncate(value, maximum) when is_integer(value) do
    value
    |> Integer.to_string()
    |> String.slice(0, maximum)
  end
end
