defmodule AirHockeyBackendWeb.Presence do
  use Phoenix.Presence, otp_app: :air_hockey_backend, pubsub_server: AirHockeyBackend.PubSub
end