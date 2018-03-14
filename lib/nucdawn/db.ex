defmodule Nucdawn.Db do
  use GenServer
  require Logger

  @table :db

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    table = PersistentEts.new(@table, "db.tab", [:named_table, :public])
    Logger.info("Persistent ETS table #{@table} created")

    {:ok, table}
  end

  def add_karma(type, channel, subject) do
    # Increment subject's karma by one; default value of 0 (before incrementation) if subject
    # isn't already in the table
    @table
    |> :ets.update_counter({type, channel, subject}, {2, 1}, {{type, channel, subject}, 0})
  end

  def get_karma(type, channel, subject) do
    @table
    |> :ets.match({{type, channel, subject}, :"$1"})
    |> List.flatten()
    |> List.first()
    |> case do
      nil -> 0
      n -> n
    end
  end

  def get_top_karma(type, channel) do
    # Get all scores of a certain type from channel, sort by score, descending, take top 5
    @table
    |> :ets.match_object({{type, channel, :_}, :_})
    |> List.keysort(1)
    |> Enum.reverse()
    |> Enum.take(5)
    |> Enum.reduce([], fn x, acc ->
      {{_, _, subject}, score} = x
      acc ++ ["#{subject} (#{score})"]
    end)
  end
end
