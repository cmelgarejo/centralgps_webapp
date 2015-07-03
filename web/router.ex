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
    get  "/",               MonitorController, :index
    get  "/assets",         MonitorController, :assets
    get  "/assets/record",  MonitorController, :record
    #Checkpoint Module
    get  "/assets/checkpoint/marks", Checkpoint.MonitorController, :marks
    get  "/venues",                  Checkpoint.MonitorController, :venues
  end

  scope "/profile", CentralGPSWebApp.Client do
    pipe_through :browser # Use the default browser stack
    get  "/", ProfileController, :index
  end

  scope "/security/accounts", CentralGPSWebApp.Client.Security do
    pipe_through :browser # Use the default browser stack
    get    "/",       AccountController, :index
    get    "/json",   AccountController, :list
    get    "/new",    AccountController, :new
    get    "/edit",   AccountController, :edit
    post   "/save",   AccountController, :save
    delete "/delete", AccountController, :delete
  end

  scope "/checkpoint/actions", CentralGPSWebApp.Client.Checkpoint do
    pipe_through :browser # Use the default browser stack
    get    "/",       ActionController, :index
    get    "/json",   ActionController, :list
    get    "/new",    ActionController, :new
    get    "/edit",   ActionController, :edit
    post   "/save",   ActionController, :save
    delete "/delete", ActionController, :delete
  end

  scope "/checkpoint/reasons", CentralGPSWebApp.Client.Checkpoint do
    pipe_through :browser # Use the default browser stack
    get    "/",       ReasonController, :index
    get    "/json",   ReasonController, :list
    get    "/new",    ReasonController, :new
    get    "/edit",   ReasonController, :edit
    post   "/save",   ReasonController, :save
    delete "/delete", ReasonController, :delete
  end

  scope "/checkpoint/venue_types", CentralGPSWebApp.Client.Checkpoint do
    pipe_through :browser # Use the default browser stack
    get    "/",       VenueTypeController, :index
    get    "/json",   VenueTypeController, :list
    get    "/new",    VenueTypeController, :new
    get    "/edit",   VenueTypeController, :edit
    post   "/save",   VenueTypeController, :save
    delete "/delete", VenueTypeController, :delete
  end

  scope "/checkpoint/venues", CentralGPSWebApp.Client.Checkpoint do
    pipe_through :browser # Use the default browser stack
    get    "/",       VenueController, :index
    get    "/json",   VenueController, :list
    get    "/new",    VenueController, :new
    get    "/edit",   VenueController, :edit
    post   "/save",   VenueController, :save
    delete "/delete", VenueController, :delete
  end

  scope "/entity", CentralGPSWebApp.Entity do
    pipe_through :browser # Use the default browser stack

    get "/", LoginController, :login
  end
end
