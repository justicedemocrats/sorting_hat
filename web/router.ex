defmodule SortingHat.Router do
  use SortingHat.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:put_secure_browser_headers)
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(SortingHat.SecretPlug)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(SortingHat.SecretPlug)
  end

  scope "/", SortingHat do
    pipe_through(:browser)
    get("/", PageController, :index)
    post("/", PageController, :queue)
  end

  scope "/api", SortingHat do
    pipe_through(:api)
    post("/lookup", LookupController, :lookup)
  end
end
