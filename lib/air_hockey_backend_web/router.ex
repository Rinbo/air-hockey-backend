defmodule AirHockeyBackendWeb.Router do
  use AirHockeyBackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: "http://localhost:3000"
  end

  scope "/", AirHockeyBackendWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/channels", AirHockeyBackendWeb do
    pipe_through :api

    get "/", ChannelController, :index
  end
end
