defmodule AirHockeyBackendWeb.GameChannel do
  use AirHockeyBackendWeb, :channel

  def join("game:" <> game_name, %{"player_name" => name }, socket) do
    IO.puts("=============")
    IO.inspect(socket)
    IO.puts("=============")

   {:ok, assign(socket, :lobby, name)}
  end
  
  def handle_in("ping", _payload, socket) do
    IO.puts("=============")
    IO.inspect(socket)
    IO.puts("=============")
    {:noreply, socket}
  end

end