defmodule AirHockeyBackendWeb.LobbyChannel do
  use AirHockeyBackendWeb, :channel

  def join("lobby:main", %{"player_name" => name }, socket) do
    IO.puts("=============")
    IO.inspect(socket)
    IO.puts("=============")
    {:ok, assign(socket, :lobby, name)}
  end

  def handle_in("game_created", payload, socket) do
    IO.puts("====EXTERNAL CALL====")
    IO.inspect(payload)
    IO.puts("====EXTERNAL CALL====")
    broadcast! socket, "game_created", payload
    {:noreply, assign(socket, :lobby, payload.game_name)}
  end

end