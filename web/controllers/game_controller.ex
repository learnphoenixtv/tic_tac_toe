defmodule TicTacToe.GameController do
  use TicTacToe.Web, :controller

  def new(conn, _params) do
    game_id = UUID.uuid4()
    redirect conn, to: game_path(conn, :show, game_id)
  end

  def show(conn, _params) do
    render conn, "show.html"
  end
end
