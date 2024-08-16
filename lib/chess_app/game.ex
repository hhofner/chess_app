defmodule ChessApp.Game do
  require Logger

  def create_game do
    game_id = generate_game_id()
    case ChessApp.GameSupervisor.start_game(game_id) do
      {:ok, _pid} -> 
        game_id
      {:error, reason} ->
        Logger.error("Failed to create game: #{inspect(reason)}")
        nil
    end
  end

  def get_game(game_id) do
    ChessApp.GameServer.get_state(game_id)
  end

  def join_game(game_id, player) do
    ChessApp.GameServer.join_game(game_id, player)
  end

  defp generate_game_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64 |> binary_part(0, 8)
  end
end
