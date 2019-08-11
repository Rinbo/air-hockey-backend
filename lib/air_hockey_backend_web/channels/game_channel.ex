defmodule AirHockeyBackendWeb.GameChannel do
  use AirHockeyBackendWeb, :channel

  def join("game:" <> game_name, %{"player_name" => name }, socket) do
    #first check that it is the player that created the channel    
    send(self(), {:add_game_to_lobby, game_name })
    {:ok, assign(socket, :game_name, game_name)}
  end

  def handle_info({:add_game_to_lobby, game_name}, socket) do
    AirHockeyBackendWeb.Endpoint.broadcast_from!(self(), "lobby:main",
    "game_created", %{game_name: game_name})
    {:noreply, socket}
  end


end