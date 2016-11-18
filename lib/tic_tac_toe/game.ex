defmodule TicTacToe.Game do
  use GenServer

  alias TicTacToe.Matrix

  def join(game) do
    GenServer.call(game, :join)
  end

  def select(game, coord) do
    GenServer.call(game, {:select, coord})
  end

  def winner(game) do
    GenServer.call(game, :winner)
  end

  def board(game) do
    GenServer.call(game, :board)
  end

  def my_turn?(game, player) do
    GenServer.call(game, {:my_turn, player})
  end

  ###
  # GenServer API
  ###

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    board = [
      [nil, nil, nil],
      [nil, nil, nil],
      [nil, nil, nil]
    ]

    state = %{
      board: Matrix.from_list(board),
      player: "X",
      players_joined: 0,
      status: :in_progress,
      winner: nil
    }

    {:ok, state}
  end

  def handle_call(:join, _from, state) do
    case state.players_joined do
      0 ->
        {:reply, {:ok, :waiting, "X"}, %{state | players_joined: 1}}
      1 ->
        {:reply, {:ok, :ready, "O"}, %{state | players_joined: 2}}
      _ ->
        {:reply, {:error, "Game is already full"}, state}
    end
  end

  def handle_call({:select, [x, y]}, _from, %{players_joined: 2} = state) do
    case get_in(state.board, [x, y]) do
      nil ->
        state =
          state
          |> put_in([:board, x, y], state.player)
          |> next_player
          |> update_winner
          |> update_status

        {:reply, {:ok, state.status, Matrix.to_list(state.board)}, state}
      _other ->
        {:reply, {:error, "Space already taken"}, state}
    end
  end
  def handle_call({:select, [x, y]}, _from, state) do
    {:reply, {:error, "Waiting for players"}, state}
  end

  def handle_call(:winner, _from, state) do
    {:reply, state.winner, state}
  end

  def handle_call(:board, _from, state) do
    {:reply, Matrix.to_list(state.board), state}
  end

  def handle_call({:my_turn, player}, _from, state) do
    {:reply, state.player == player, state}
  end

  defp next_player(%{player: "X"} = state), do: %{state | player: "O"}
  defp next_player(%{player: "O"} = state), do: %{state | player: "X"}

  defp update_winner(state) do
    winner =
      case Matrix.to_list(state.board) do
        [[a, a, a],
         [_, _, _],
         [_, _, _]] when a != nil -> a

        [[_, _, _],
         [a, a, a],
         [_, _, _]] when a != nil -> a

        [[_, _, _],
         [_, _, _],
         [a, a, a]] when a != nil -> a

        [[a, _, _],
         [a, _, _],
         [a, _, _]] when a != nil -> a

        [[_, a, _],
         [_, a, _],
         [_, a, _]] when a != nil -> a

        [[_, _, a],
         [_, _, a],
         [_, _, a]] when a != nil -> a

        [[a, _, _],
         [_, a, _],
         [_, _, a]] when a != nil -> a

        [[_, _, a],
         [_, a, _],
         [a, _, _]] when a != nil -> a

        _other ->
          nil
      end

    %{state | winner: winner}
  end

  defp update_status(%{winner: winner} = state) when winner != nil do
    %{state | status: :complete}
  end
  defp update_status(state) do
    filled? =
      state.board
      |> Matrix.to_list
      |> List.flatten
      |> Enum.all?(&(&1 != nil))

    if filled? do
      %{state | status: :complete}
    else
      %{state | status: :in_progress}
    end
  end
end
