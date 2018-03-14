defmodule Nucdawn.Karma do
  import Kaguya.Module
  import Nucdawn.Helpers

  defp rate_limit_karma_scale, do: Application.get_env(:nucdawn, :rate_limit_karma_scale)

  defh add_karma(%{"subject" => subject}) do
    channel = message.args |> List.to_string()
    rate_limit_string = channel <> message.user.nick <> message.trailing

    case ExRated.check_rate(rate_limit_string, rate_limit_karma_scale(), 1) do
      {:ok, _} -> add_karma(channel, subject, message)
      {:error, _} -> reply "Not so fast, buddy boy."
    end
  end

  defp add_karma(channel, subject, message) do
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

  defh remove_karma do
    reply "Love can only be given, #{message.user.nick}."
  end

  defh show_karma do
    channel = message.args |> List.to_string()

    message.trailing
    |> String.slice(7, 23)
    |> check_input(message.user.nick)
    |> get_karma(channel)
    |> truncate(400)
    |> reply()
  end

  defp check_input(input, nick \\ nil) do
    # Thanks to Phrogz @ https://stackoverflow.com/a/5163309
    case Regex.run(~r/\A[a-z_\-\[\]\\^{}|`][a-z0-9_\-\[\]\\^{}|`]{1,15}\z/i, input) do
      nil -> nick
      n -> List.first(n)
    end
  end

  defp get_top_karma(nil, channel) do
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
