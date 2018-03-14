defmodule Nucdawn.Karma do
  import Kaguya.Module
  import Nucdawn.Helpers

  defh add_karma(%{"subject" => subject}) do
    channel = message.args |> List.to_string()

    Nucdawn.Db.add_karma("karma", channel, subject)
    Nucdawn.Db.add_karma("karma-giver", channel, message.user.nick)

    current_karma = Nucdawn.Db.get_karma("karma", channel, subject)

    "#{subject} has a karma of #{current_karma}."
    |> truncate(400)
    |> reply()
  end

  defh show_karma do
    channel = message.args |> List.to_string()

    message.trailing
    |> check_input()
    |> get_karma(channel)
    |> truncate(400)
    |> reply()
  end

  defp check_input(input) do
    case Regex.run(~r/.karma\s?([a-z0-9]+)/, input, capture: :all_but_first) do
      nil -> nil
      n -> List.first(n)
    end
  end

  defp get_karma(nil, channel) do
    receivers = Nucdawn.Db.get_top_karma("karma", channel)
    givers = Nucdawn.Db.get_top_karma("karma-giver", channel)

    case receivers do
      [] ->
        "Nobody's got positive karma."

      _ ->
        "Top receivers of Internet points: " <>
          Enum.join(receivers, ", ") <> " | Top givers: " <> Enum.join(givers, ", ")
    end
  end

  defp get_karma(subject, channel) do
    received = Nucdawn.Db.get_karma("karma", channel, subject)
    given = Nucdawn.Db.get_karma("karma-giver", channel, subject)

    "#{subject} has received #{received} Internet points and given #{given}."
  end
end
