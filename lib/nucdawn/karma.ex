defmodule Nucdawn.Karma do
  import Kaguya.Module
  import Nucdawn.Helpers

  defh add_karma(%{"subject" => subject}) do
    IO.inspect message
    channel = message.args |> List.to_string()

    cond do
      String.downcase(message.user.nick) == String.downcase(subject) ->
        Nucdawn.Db.add_karma("karma", channel, String.downcase(subject), -1)
        current_karma = Nucdawn.Db.get_karma("karma", channel, String.downcase(subject))
        reply "#{subject}: -1 for narcissism. You now have #{current_karma}."
      check_input(subject) ->
        Nucdawn.Db.add_karma("karma", channel, String.downcase(subject), 1)
        Nucdawn.Db.add_karma("karma-giver", channel, String.downcase(message.user.nick), 1)

        current_karma = Nucdawn.Db.get_karma("karma", channel, String.downcase(subject))

        "#{subject} now has a karma of #{current_karma}."
        |> truncate(400)
        |> reply()
    end
  end

  defh show_karma do
    channel = message.args |> List.to_string()

    message.trailing
    |> String.slice(7, 23)
    |> check_input()
    |> get_karma(channel)
    |> truncate(400)
    |> reply()
  end

  defp check_input(input) do
    # Thanks to Phrogz @ https://stackoverflow.com/a/5163309
    case Regex.run(~r/\A[a-z_\-\[\]\\^{}|`][a-z0-9_\-\[\]\\^{}|`]{1,15}\z/i, input) do
      nil -> nil
      n -> List.first(n)
    end
  end

  defp get_karma(nil, channel) do
    receivers = Nucdawn.Db.get_top_karma("karma", channel)
    givers = Nucdawn.Db.get_top_karma("karma-giver", channel)

    case receivers do
      [] ->
        "Nobody's got karma."

      _ ->
        "Top receivers of Internet points: " <>
          Enum.join(receivers, ", ") <> " | Top givers: " <> Enum.join(givers, ", ")
    end
  end

  defp get_karma(subject, channel) do
    received = Nucdawn.Db.get_karma("karma", channel, String.downcase(subject))
    given = Nucdawn.Db.get_karma("karma-giver", channel, String.downcase(subject))

    "#{subject} has received #{received} Internet points and given #{given}."
  end
end
