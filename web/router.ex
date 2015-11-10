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
    get  "/assets/roadmap",  MonitorController, :roadmap
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
    #Client
    get    "/clients/",       ClientController, :index
    get    "/clients/json",   ClientController, :list
    get    "/clients/new",    ClientController, :new
    get    "/clients/edit",   ClientController, :edit
    post   "/clients/save",   ClientController, :save
    delete "/clients/delete", ClientController, :delete
    #Client Contacts
    get    "/clients/contacts/",       ClientContactController, :index
    get    "/clients/contacts/json",   ClientContactController, :list
    get    "/clients/contacts/new",    ClientContactController, :new
    get    "/clients/contacts/edit",   ClientContactController, :edit
    post   "/clients/contacts/save",   ClientContactController, :save
    delete "/clients/contacts/delete", ClientContactController, :delete
    #Item
    get    "/items/",       ItemController, :index
    get    "/items/json",   ItemController, :list
    get    "/items/new",    ItemController, :new
    get    "/items/edit",   ItemController, :edit
    post   "/items/save",   ItemController, :save
    delete "/items/delete", ItemController, :delete
    #Measure Unit
    get    "/measure_units/",       MeasureUnitController, :index
    get    "/measure_units/json",   MeasureUnitController, :list
    get    "/measure_units/new",    MeasureUnitController, :new
    get    "/measure_units/edit",   MeasureUnitController, :edit
    post   "/measure_units/save",   MeasureUnitController, :save
    delete "/measure_units/delete", MeasureUnitController, :delete
    #Forms
    get    "/forms/",       FormController, :index
    get    "/forms/json",   FormController, :list
    get    "/forms/new",    FormController, :new
    get    "/forms/edit",   FormController, :edit
    post   "/forms/save",   FormController, :save
    delete "/forms/delete", FormController, :delete
    #Form Templates
    get    "/form_templates/",       FormTemplateController, :index
    get    "/form_templates/json",   FormTemplateController, :list
    get    "/form_templates/new",    FormTemplateController, :new
    get    "/form_templates/edit",   FormTemplateController, :edit
    post   "/form_templates/save",   FormTemplateController, :save
    delete "/form_templates/delete", FormTemplateController, :delete
    #Activities
    get    "/activities/",       ActivityController, :index
    get    "/activities/json",   ActivityController, :list
    get    "/activities/new",    ActivityController, :new
    get    "/activities/edit",   ActivityController, :edit
    post   "/activities/save",   ActivityController, :save
    delete "/activities/delete", ActivityController, :delete
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
    post   "/roadmap_point_venue_form/save",   RoadmapPointVenueForm, :save
    delete "/roadmap_point_venue_form/delete", RoadmapPointVenueForm, :delete
  end

  scope "/client", CentralGPSWebApp.Client do
    pipe_through :browser # Use the default browser stack
    #Assets
    get    "/assets/",       AssetController, :index
    get    "/assets/json",   AssetController, :list
    get    "/assets/new",    AssetController, :new
    get    "/assets/edit",   AssetController, :edit
    post   "/assets/save",   AssetController, :save
    delete "/assets/delete", AssetController, :delete
    #Asset/Roadmap
    get    "/assets/roadmap",        AssetRoadmapController, :index
    get    "/assets/roadmap/json",   AssetRoadmapController, :list
    get    "/assets/roadmap/new",    AssetRoadmapController, :new
    get    "/assets/roadmap/edit",   AssetRoadmapController, :edit
    post   "/assets/roadmap/save",   AssetRoadmapController, :save
    delete "/assets/roadmap/delete", AssetRoadmapController, :delete
    #Roadmaps
    get    "/roadmap/",       RoadmapController, :index
    get    "/roadmap/json",   RoadmapController, :list
    get    "/roadmap/new",    RoadmapController, :new
    get    "/roadmap/edit",   RoadmapController, :edit
    get    "/roadmap/read",   RoadmapController, :view
    post   "/roadmap/save",   RoadmapController, :save
    delete "/roadmap/delete", RoadmapController, :delete
    #Roadmap points
    get    "/roadmap/point/",       RoadmapPointController, :index
    get    "/roadmap/point/json",   RoadmapPointController, :list
    get    "/roadmap/point/new",    RoadmapPointController, :new
    get    "/roadmap/point/edit",   RoadmapPointController, :edit
    post   "/roadmap/point/save",   RoadmapPointController, :save
    put    "/roadmap/point/order",  RoadmapPointController, :order
    delete "/roadmap/point/delete", RoadmapPointController, :delete
  end

  scope "/entity", CentralGPSWebApp.Entity do
    pipe_through :browser # Use the default browser stack

    get "/", LoginController, :login
  end
end
