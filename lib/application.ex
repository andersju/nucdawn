defmodule Nucdawn.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Nucdawn.Db, []),
      {DynamicSupervisor, strategy: :one_for_one, name: Nucdawn.RandomlySupervisor},
      worker(Task, [&Nucdawn.RandomlyStarter.start/0], restart: :temporary)
    ]

    opts = [strategy: :one_for_one, name: Nucdawn.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
