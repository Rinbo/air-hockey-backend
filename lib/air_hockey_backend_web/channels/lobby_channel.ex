defmodule AirHockeyBackendWeb.LobbyChannel do
  use AirHockeyBackendWeb, :channel

  def join("lobby:main", %{"player_name" => name }, socket) do
    {:ok, assign(socket, :lobby, name)}
  end

end