defmodule AirHockeyBackendWeb.GameChannel do
  use AirHockeyBackendWeb, :channel

  alias AirHockeyBackendWeb.Presence

  def join("game:" <> game_name, %{"player_name" => name }, socket) do
    send(self(), {:after_join, name})
    unless game_name == "lobby" do
      send(self(), {:topic_created, game_name})
    end
    {:ok, socket}
  end

  def handle_info({:after_join, name}, socket) do
    {:ok, _} = Presence.track(socket, name, %{online_at: inspect(System.system_time(:seconds))})
    {:noreply, socket}
  end

  def handle_info({:topic_created, game_name}, socket) do
    
    IO.puts("NEW GAME CREATED")
    IO.inspect(socket)
    IO.puts("NEW GAME CREATED")
    {:noreply, socket} 
  end
  
  def handle_in("ping", _payload, socket) do
    IO.puts("=============")
    IO.inspect(socket)
    IO.puts("=============")
    {:noreply, socket}
  end

end