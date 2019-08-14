defmodule AirHockeyBackendWeb.GameChannel do
  use AirHockeyBackendWeb, :channel

  alias AirHockeyBackendWeb.Presence

  def join("game:" <> game_name, %{"player_name" => name }, socket) do
    send(self(), {:after_join, name})    
    {:ok, socket}
  end

  def handle_info({:after_join, name}, socket) do
    :ok = Phoenix.PubSub.subscribe(
              socket.pubsub_server,
              "subtopic_listing",
              fastlane: {socket.transport_pid, socket.serializer, []}
            )
      

    {:ok, _} = Presence.track(self(), "subtopic_listing", name, %{online_at: inspect(System.system_time(:seconds)), topic: socket.topic})
    {:noreply, socket}
  end
  
  def handle_in("get_active_games", _payload, socket) do
    IO.puts("This function was called")
    games = list_active_unique_games()
    broadcast!(socket, "active_games", %{games: games})
    {:noreply, socket}
  end

  defp list_active_unique_games() do
    Presence.list("subtopic_listing")
    |> Map.values
    |> Enum.map(fn element -> 
      %{ metas: [%{online_at: _, phx_ref: _, topic: "game:" <> g_name}]} = element
      g_name
    end)
    |> Enum.uniq
    |> Enum.filter(fn game_name -> game_name != "lobby" end)    
  end

end
