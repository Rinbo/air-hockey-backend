defmodule AirHockeyBackendWeb.UserSocket do
  use Phoenix.Socket

  channel "game:*", AirHockeyBackendWeb.GameChannel
  channel "lobby:*", AirHockeyBackendWeb.LobbyChannel

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
