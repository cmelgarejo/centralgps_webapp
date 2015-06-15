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
    post "/logout", LoginController, :logout
  end

  scope "/monitor", CentralGPSWebApp.Client do
    pipe_through :browser # Use the default browser stack
    get  "/",       MonitorController, :index
    get  "/assets", MonitorController, :assets
    get  "/assets/checkpoint/marks", Checkpoint.MonitorController, :marks
    get  "/venues",                  Checkpoint.MonitorController, :venues
  end

  scope "/profile", CentralGPSWebApp.Client do
    pipe_through :browser # Use the default browser stack
    get  "/", ProfileController, :index
  end

  scope "/checkpoint/actions", CentralGPSWebApp.Client.Checkpoint do
    pipe_through :browser # Use the default browser stack
    get  "/",       ActionController, :index
    get  "/json",   ActionController, :list
    get  "/new",    ActionController, :new
    get  "/edit",   ActionController, :edit
    post "/save",   ActionController, :save
    post "/delete", ActionController, :delete
  end

  scope "/entity", CentralGPSWebApp.Entity do
    pipe_through :browser # Use the default browser stack

    get "/", LoginController, :login
  end
end
