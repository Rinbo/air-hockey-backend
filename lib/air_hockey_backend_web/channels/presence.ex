defmodule AirHockeyBackendWeb.Presence do
  use Phoenix.Presence, otp_app: :air_hockey_backend, pubsub_server: AirHockeyBackend.PubSub

  def do_game_update(pid, key, user, %{status: status, topic: topic, player_count: player_count}) do
    AirHockeyBackendWeb.Presence.update(pid, key, user, %{
      status: status,
      topic: topic,
      user: user,
      player_count: player_count
    })
  end

end