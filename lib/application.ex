defmodule Nucdawn.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Nucdawn.Db, [])
    ]

    opts = [strategy: :one_for_one, name: Nucdawn.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
