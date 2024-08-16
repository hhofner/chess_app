defmodule ChessAppWeb.GameLive do
  use ChessAppWeb, :live_view 
  alias ChessApp.Game 

  @impl true
  def mount(%{"id" => game_id}, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)

    case Game.get_game(game_id) do
      %{} = game -> {:ok, assign(socket, game: game, game_id: game_id)}
      nil -> {:ok, push_redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_event("join", _params, socket) do
    case Game.join_game(socket.assigns.game_id, "Player") do
      {:ok, color} ->
        {:noreply, put_flash(socket, :info, "Joined as #{color}")}
      {:error, :game_full} ->
        {:noreply, put_flash(socket, :error, "Game is full")}
    end
  end

  @impl true
  def handle_info(:update, socket) do
    game = Game.get_game(socket.assigns.game_id)
    Process.send_after(self(), :update, 1000)
    {:noreply, assign(socket, game: game)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Chess Game</h1>
    <p>Game ID: <%= @game_id %></p>
    <p>Status: <%= @game.status %></p>
    <p>White Player: <%= @game.white_player || "Waiting..." %></p>
    <p>Black Player: <%= @game.black_player || "Waiting..." %></p>
    <button phx-click="join">Join Game</button>

    <div class="flex justify-center items-center">
      <div class="grid grid-rows-8 grid-cols-8">
        <%= for row <- ["8", "7", "6", "5", "4", "3", "2", "1"] do %>
          <%= for col <- ["a", "b", "c", "d", "e", "f", "g", "h"] do %>
            <div class={"square #{if rem(String.to_integer(row) + :binary.first(col) - 97, 2) == 0, do: "light", else: "dark"}"}>
              <%= "#{col}#{row}" %>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
