defmodule ChessApp.GameServer do
  use GenServer
  
  # Client API

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
  end

  def get_state(game_id) do
    GenServer.call(via_tuple(game_id), :get_state)
  end

  def join_game(game_id, player) do
    GenServer.call(via_tuple(game_id), {:join_game, player})
  end

  # Server Callbacks

  @impl true
  def init(game_id) do
    {:ok, %{id: game_id, white_player: nil, black_player: nil, status: :waiting}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:join_game, player}, _from, state) do
    cond do
      state.white_player == nil ->
        new_state = %{state | white_player: player}
        {:reply, {:ok, :white}, new_state}
      state.black_player == nil ->
        new_state = %{state | black_player: player, status: :in_progress}
        {:reply, {:ok, :black}, new_state}
      true ->
        {:reply, {:error, :game_full}, state}
    end
  end

  defp via_tuple(game_id) do
    {:via, Registry, {ChessApp.GameRegistry, game_id}}
  end
end
