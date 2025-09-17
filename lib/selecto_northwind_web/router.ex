defmodule SelectoNorthwindWeb.Router do
  use SelectoNorthwindWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SelectoNorthwindWeb.Layouts, :root}
    plug :put_layout, html: {SelectoNorthwindWeb.Layouts, :app}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SelectoNorthwindWeb do
    pipe_through :browser

    get "/", PageController, :home

    # Note: These placeholder routes will be replaced with LiveView routes
    # during the tutorial as you generate Selecto domains for each section
    get "/customers_selecto", PageController, :customers_selecto
    live "/products_selecto", ProductLive, :index
    get "/orders_selecto", PageController, :orders_selecto
    get "/analytics", PageController, :analytics
  end

  # Other scopes may use custom stacks.
  # scope "/api", SelectoNorthwindWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:selecto_northwind, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SelectoNorthwindWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
