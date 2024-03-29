defmodule ShortLinksWeb.Router do
  use ShortLinksWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShortLinksWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShortLinksWeb do
    pipe_through :browser

    get "/stats/csv/", LinkController, :stats_csv
    get "/stats/:slug", LinkController, :show
    get "/stats", LinkController, :stats

    get "/:slug", RedirectController, :execute_link

    get "/", LinkController, :new
    post "/", LinkController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShortLinksWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:short_links, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShortLinksWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
