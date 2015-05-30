defmodule CentralGPSWebApp.Router do
  use CentralGPSWebApp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    #plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CentralGPSWebApp.Client do
    pipe_through :browser # Use the default browser stack

    get  "/", MainController, :index

    get  "ping", PingController, :ping

    get  "/login",  LoginController, :index
    post "/login",  LoginController, :login
    get  "/logout", LoginController, :logout
    post  "/logout", LoginController, :logout

    get  "/monitor", MonitorController, :index
    get  "/monitor/assets", MonitorController, :assets
    get  "/monitor/assets/checkpoint/marks", MonitorController, :checkpoint_mark
  end

  scope "/entity", CentralGPSWebApp.Entity do
    pipe_through :browser # Use the default browser stack

    get "/", LoginController, :login
  end
end
