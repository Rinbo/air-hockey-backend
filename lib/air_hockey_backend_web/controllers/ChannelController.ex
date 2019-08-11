defmodule AirHockeyBackendWeb.ChannelController do
  use AirHockeyBackendWeb, :controller

  def index(conn, params) do
    IO.puts("=============")
    IO.inspect(conn)
    IO.puts("=============")
    json(conn, %{channels: "No channels here"})
  end
end