defmodule Nucdawn.RandomlyStarter do
  def start do
    Enum.each(Application.get_env(:nucdawn, :random_channels), fn channel ->
      DynamicSupervisor.start_child(Nucdawn.RandomlySupervisor, {Nucdawn.Randomly, [channel]})
    end)
  end
end
