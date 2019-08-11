defmodule AirHockeyBackendWeb.PageController do
  use AirHockeyBackendWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
