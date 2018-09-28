# Randomly say crap.
# From example from https://stackoverflow.com/a/32097971
defmodule Nucdawn.Randomly do
  use GenServer

  defp random_strings, do: Application.get_env(:nucdawn, :random_strings)

  def start_link(channel) do
    GenServer.start_link(__MODULE__, channel)
  end

  def init(channel) do
    schedule_work()
    {:ok, channel}
  end

  def handle_info(:work, channel) do
    random_strings()
    |> Enum.take_random(1)
    |> hd
    |> Kaguya.Util.sendPM(channel)

    schedule_work()
    {:noreply, channel}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, Enum.random(3600*8..3600*20) * 1000)
  end
end