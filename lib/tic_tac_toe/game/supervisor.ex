defmodule TicTacToe.Game.Supervisor do
  def start_link do
    import Supervisor.Spec

    children = [
      worker(TicTacToe.Game, [])
    ]

    opts = [strategy: :simple_one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def new_game(id) do
    Supervisor.start_child(__MODULE__, [[name: find_game(id)]])
  end

  def find_game(id) do
    {:via, Registry, {TicTacToe.Game.Registry, id}}
  end
end
