defmodule CentralGPSWebApp.Router do
  use CentralGPSWebApp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    #plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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
    get  "/",                 MonitorController, :index
    get  "/assets",           MonitorController, :assets
    get  "/assets/record",    MonitorController, :record
    get  "/assets/roadmaps",  MonitorController, :roadmap
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

  scope "/checkpoint", CentralGPSWebApp.Client.Checkpoint do
    pipe_through :browser # Use the default browser stack
    #Actions
    get    "/actions/",       ActionController, :index
    get    "/actions/json",   ActionController, :list
    get    "/actions/new",    ActionController, :new
    get    "/actions/edit",   ActionController, :edit
    post   "/actions/save",   ActionController, :save
    delete "/actions/delete", ActionController, :delete
    #Reasons
    get    "/reasons/",       ReasonController, :index
    get    "/reasons/json",   ReasonController, :list
    get    "/reasons/new",    ReasonController, :new
    get    "/reasons/edit",   ReasonController, :edit
    post   "/reasons/save",   ReasonController, :save
    delete "/reasons/delete", ReasonController, :delete
    #Venue types
    get    "/venue_types/",       VenueTypeController, :index
    get    "/venue_types/json",   VenueTypeController, :list
    get    "/venue_types/new",    VenueTypeController, :new
    get    "/venue_types/edit",   VenueTypeController, :edit
    post   "/venue_types/save",   VenueTypeController, :save
    delete "/venue_types/delete", VenueTypeController, :delete
    #Venues
    get    "/venues/",       VenueController, :index
    get    "/venues/json",   VenueController, :list
    get    "/venues/new",    VenueController, :new
    get    "/venues/edit",   VenueController, :edit
    post   "/venues/save",   VenueController, :save
    delete "/venues/delete", VenueController, :delete
    #Roadmap point / Venue
    post   "/roadmap_point_venue/save",   RoadmapPointVenue, :save
    delete "/roadmap_point_venue/delete", RoadmapPointVenue, :delete
  end

  scope "/client", CentralGPSWebApp.Client do
    pipe_through :browser # Use the default browser stack
    #Asset/Roadmap
    get    "/assets/roadmaps/json", AssetRoadmapController, :list_all
    get    "/assets/:asset_id/roadmaps/",       AssetRoadmapController, :index
    get    "/assets/:asset_id/roadmaps/json",   AssetRoadmapController, :list
    get    "/assets/:asset_id/roadmaps/new",    AssetRoadmapController, :new
    get    "/assets/:asset_id/roadmaps/edit",   AssetRoadmapController, :edit
    post   "/assets/:asset_id/roadmaps/save",   AssetRoadmapController, :save
    delete "/assets/:asset_id/roadmaps/delete", AssetRoadmapController, :delete
    #Roadmaps
    get    "/roadmaps/",       RoadmapController, :index
    get    "/roadmaps/json",   RoadmapController, :list
    get    "/roadmaps/new",    RoadmapController, :new
    get    "/roadmaps/edit",   RoadmapController, :edit
    get    "/roadmaps/read",   RoadmapController, :view
    post   "/roadmaps/save",   RoadmapController, :save
    delete "/roadmaps/delete", RoadmapController, :delete
    #Roadmap points
    get    "/roadmaps/points/",       RoadmapPointController, :index
    get    "/roadmaps/points/json",   RoadmapPointController, :list
    get    "/roadmaps/points/new",    RoadmapPointController, :new
    get    "/roadmaps/points/edit",   RoadmapPointController, :edit
    post   "/roadmaps/points/save",   RoadmapPointController, :save
    delete "/roadmaps/points/delete", RoadmapPointController, :delete
  end

  scope "/entity", CentralGPSWebApp.Entity do
    pipe_through :browser # Use the default browser stack

    get "/", LoginController, :login
  end
end
