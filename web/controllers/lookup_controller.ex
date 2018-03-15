defmodule SortingHat.LookupController do
  use SortingHat.Web, :controller
  import ShortMaps

  def lookup(conn, params) do
    result = SortingHat.Lookup.lookup(params["phone"] || params["phones"])
    json(conn, result)
  end
end
