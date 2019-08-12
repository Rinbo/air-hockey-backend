defmodule AirHockeyBackendWeb.GameChannel do
  use AirHockeyBackendWeb, :channel

  alias AirHockeyBackendWeb.Presence

  def join("game:" <> game_name, %{"player_name" => name }, socket) do
    send(self(), {:after_join, game_name})
    {:ok, socket}
  end

  def handle_info({:after_join, game_name}, socket) do
    {:ok, _} = Presence.track(socket, game_name, %{online_at: inspect(System.system_time(:seconds))})
    {:noreply, socket}
  end

  
  def handle_in("ping", _payload, socket) do
    IO.puts("=============")
    IO.inspect(Presence.list())
    IO.puts("=============")
    {:noreply, socket}
  end

end