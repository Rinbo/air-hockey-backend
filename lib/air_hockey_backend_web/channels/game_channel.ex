defmodule AirHockeyBackendWeb.GameChannel do
  use AirHockeyBackendWeb, :channel

  alias AirHockeyBackendWeb.Presence
  alias AirHockeyBackend.GameState

  def join("game:" <> _game_name, %{"player_name" => name }, socket) do
    if authorized?(socket, name) do
      send(self(), {:after_join, name})
      {:ok, assign(socket, :game_state, %GameState{})}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info({:after_join, name}, socket) do
    :ok = Phoenix.PubSub.subscribe(
              socket.pubsub_server,
              "subtopic_listing",
              fastlane: {socket.transport_pid, socket.serializer, []}
            )      
    {:ok, _} = Presence.track(self(), "subtopic_listing", name, %{online_at: inspect(System.system_time(:seconds)), topic: socket.topic})
    {:ok, _} = Presence.track(socket, name, %{online_at: inspect(System.system_time(:seconds))})
    
    case number_of_players(socket) do
      1 -> push socket, "player_joined", %{message: "master" }
      2 -> 
        push socket, "player_joined", %{message: "slave"}
        broadcast!(socket, "game_started", %{message: true})
    end    
    {:noreply, socket}
  end
  
  def handle_in("get_active_games", _payload, socket) do
    games = list_games_with_player_count()
    broadcast!(socket, "active_games", %{games: games})
    {:noreply, socket}
  end

  def handle_in("leave", _payload, socket) do
    broadcast!(socket, "player_left", %{message: "A player left the channel"})
    {:noreply, socket}
  end

  def handle_in("player1_update", %{"striker1" => striker1, "puck" => puck}, socket) do
    broadcast!(socket, "player1_update", %{striker1: striker1, puck: puck})
    {:noreply, assign(socket, :game_state, %GameState{socket.assigns.game_state | striker1: striker1, puck: puck})}
  end

  def handle_in("player2_update", %{"striker2" => striker2}, socket) do
    broadcast!(socket, "player2_update", %{striker2: striker2 })
    {:noreply, assign(socket, :game_state, %GameState{socket.assigns.game_state | striker2: striker2})}
  end

  defp list_games_with_player_count() do 
    total_entries = Presence.list("subtopic_listing")
    |> Map.values
    |> Enum.map(fn element -> 
      %{ metas: [%{online_at: _, phx_ref: _, topic: "game:" <> g_name}]} = element
      g_name
    end)
    |> Enum.filter(fn game_name -> game_name != "lobby" end)

    unique_entries = Enum.uniq(total_entries)

    Enum.map(unique_entries, fn x ->
      tot = Enum.count(total_entries, fn y -> y == x end)
      %{x => tot}
    end)    
  end
  defp number_of_players(socket) do
    socket
    |> Presence.list()
    |> Map.keys()
    |> length()
  end

  defp existing_player?(socket, name) do
    socket
    |> Presence.list()
    |> Map.has_key?(name)
  end

  defp authorized?(socket, name) do
    number_of_players(socket) < 2 && !existing_player?(socket, name)
  end

end
