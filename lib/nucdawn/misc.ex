defmodule Nucdawn.Misc do
  import Kaguya.Module
  import Nucdawn.Helpers

  defh rand(%{"low" => low, "high" => high}) do
    String.to_integer(low)..String.to_integer(high)
    |> Enum.random()
    |> truncate(400)
    |> reply
  end
end