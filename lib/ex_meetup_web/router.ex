defmodule ExMeetupWeb.Router do
  use ExMeetupWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExMeetupWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/admin" do
      live "/users", Admin.Users.IndexLive
      resources "/users", UserController
      resources "/payments", PaymentController
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExMeetupWeb do
  #   pipe_through :api
  # end
end
