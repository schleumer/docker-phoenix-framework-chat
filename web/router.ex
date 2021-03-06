defmodule Hellow.Router do
  use Hellow.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    #plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Hellow do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    post "/send-via-ajax", PageController, :send_via_ajax
  end

  # Other scopes may use custom stacks.
  # scope "/api", Hellow do
  #   pipe_through :api
  # end
end
