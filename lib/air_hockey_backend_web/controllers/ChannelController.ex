defmodule AirHockeyBackendWeb.ChannelController do
  use AirHockeyBackendWeb, :controller

  def index(conn, params) do
    games = Supervisor.which_children(AirHockeyBackend.Supervisor)

    IO.puts("=====")
    IO.inspect(games)
    IO.puts("=====")

    json(conn, %{channels: "No channels here"})
  end
end