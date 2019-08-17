defmodule AirHockeyBackendWeb.GameChannel do
  use AirHockeyBackendWeb, :channel

  alias AirHockeyBackendWeb.Presence

  def join("game:" <> _game_name, %{"player_name" => name }, socket) do
    if authorized?(socket, name) do
      send(self(), {:after_join, name})
      {:ok, socket}
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
    {:noreply, socket}
  end
  
  def handle_in("get_active_games", _payload, socket) do
    IO.puts("This function was called")
    games = list_games_with_player_count()
    broadcast!(socket, "active_games", %{games: games})
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

  defp authorized?(socket, name) do
    number_of_players(socket) < 2 && !existing_player?(socket, name)
  end

end
