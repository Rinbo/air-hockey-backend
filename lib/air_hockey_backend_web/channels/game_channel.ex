defmodule AirHockeyBackendWeb.GameChannel do
  use AirHockeyBackendWeb, :channel

  alias AirHockeyBackendWeb.Presence
  alias AirHockeyBackend.GameState

  def join("game:" <> game_name, %{"player_name" => name }, socket) do  
    if authorized?(socket, name, game_name) do
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
    {:ok, _} = Presence.track(self(), "subtopic_listing", name, %{online_at: inspect(System.system_time(:second)), topic: socket.topic})
   
    {:ok, _} = Presence.track(socket, name, %{online_at: inspect(System.system_time(:second))})
    
    if (socket.topic != "game:lobby") do
      case number_of_players(socket) do
        1 -> 
          send(self(), {:player1_joined, %{}})
        2 -> 
          send(self(), {:player2_joined, %{}})
      end
    end
    {:noreply, assign(socket, :name, name)}
  end

  def handle_info({ :player1_joined, _ }, socket) do
    push socket, "player_joined", %{message: "master" }
    {:noreply, socket}
  end

  def handle_info({ :player2_joined, _ }, socket) do   
    push socket, "player_joined", %{message: "slave"}
    broadcast!(socket, "game_set", %{message: true})
    {:noreply, socket}
  end

  def handle_in("start_game", _payload, socket) do
    :ok = Presence.untrack(self(), "subtopic_listing", socket.assigns.name)
    broadcast!(socket, "game_started", %{message: true, subscribers: get_subscriber_list(socket)})
    {:noreply, socket}
  end
  
  def handle_in("get_active_games", _payload, socket) do    
    games = list_games_with_player_count()
    broadcast!(socket, "active_games", %{games: games})
    {:noreply, socket}
  end

  def handle_in("leave", _payload, socket) do
    broadcast!(socket, "player_left", %{message: true})
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

  def handle_in("someone_scored", %{"score" => score}, socket) do
    broadcast!(socket, "update_score", %{score: score})
    {:noreply, assign(socket, :game_state, %GameState{socket.assigns.game_state | score: score})}
  end

  def handle_in("game_complete", _payload, socket) do    
    broadcast!(socket, "game_complete", %{})
    {:noreply, socket}
  end

  def handle_in("chat_message_out", %{"name" => name, "newMessage" => new_message}, socket) do    
    broadcast!(socket, "incoming_chat_message", %{name: name, incoming_message: new_message, timestamp: inspect(System.system_time(:second)) })
    {:noreply, socket}
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

  defp authorized?(socket, name, game_name) do
    case game_name do
      "lobby" -> true
      _ -> number_of_players(socket) < 2 && !existing_player?(socket, name)
    end
  end

  defp get_subscriber_list(socket) do
    [player1, player2] = Map.keys(Presence.list(socket))
    %{player1: player1, player2: player2}
  end

  defimpl Jason.Encoder, for: [MapSet, Range, Stream] do
    def encode(struct, opts) do
      Jason.Encode.list(Enum.to_list(struct), opts)
    end
  end
end
