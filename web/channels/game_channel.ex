defmodule TicTacToe.GameChannel do
  use TicTacToe.Web, :channel

  alias TicTacToe.Game.Supervisor, as: GameSupervisor
  alias TicTacToe.Game

  intercept ["your_turn"]

  def join("game:" <> id, _payload, socket) do
    game =
      case GameSupervisor.new_game(id) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    case Game.join(game) do
      {:ok, status, player} ->
        socket =
          socket
          |> assign(:game_id, id)
          |> assign(:player, player)
        send self, {:after_join, status}
        {:ok, socket}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  def handle_info({:after_join, status}, socket) do
    game = GameSupervisor.find_game(socket.assigns.game_id)
    broadcast(socket, "player_joined", %{player: socket.assigns.player})
    push(socket, "update_board", %{board: Game.board(game)})
    notify_turn(socket, status)

    {:noreply, socket}
  end

  def handle_in("select", %{"coord" => [x, y]}, socket) do
    game = GameSupervisor.find_game(socket.assigns.game_id)

    if Game.my_turn?(game, socket.assigns.player) do
      case Game.select(game, [String.to_integer(x), String.to_integer(y)]) do
        {:ok, status, board} ->
          broadcast(socket, "update_board", %{board: board})
          notify_turn(socket)
          notify_winner(socket, status)

          {:reply, :ok, socket}

        {:error, reason} ->
          {:reply, {:error, %{reason: reason}}, socket}
      end
    else
      {:reply, {:error, %{reason: "It isn't your turn"}}, socket}
    end
  end

  def handle_out("your_turn", payload, socket) do
    if payload.player == socket.assigns.player do
      push(socket, "your_turn", payload)
    end

    {:noreply, socket}
  end

  defp notify_turn(socket, status \\ :ready)
  defp notify_turn(socket, :waiting), do: socket
  defp notify_turn(%{assigns: %{player: player, game_id: game_id}} = socket, status) do
    game = GameSupervisor.find_game(game_id)

    current_player =
      if Game.my_turn?(game, player) do
        player
      else
        other_player(player)
      end

    broadcast(socket, "your_turn", %{player: current_player})
  end

  defp other_player("X"), do: "O"
  defp other_player("O"), do: "X"

  defp notify_winner(socket, :in_progress), do: socket
  defp notify_winner(socket, :complete) do
    winner =
      socket.assigns.game_id
      |> GameSupervisor.find_game
      |> Game.winner

    broadcast(socket, "winner", %{player: winner})
  end
end
