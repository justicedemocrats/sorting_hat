defmodule SortingHat.LookupController do
  use SortingHat.Web, :controller
  import ShortMaps

  def lookup(conn, params) do
    {result, cost} = SortingHat.Lookup.lookup(params["phone"] || params["phones"])
    json(conn, ~m(result cost))
  end
end
