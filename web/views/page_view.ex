defmodule SortingHat.PageView do
  use SortingHat.Web, :view

  def csrf_token do
    Plug.CSRFProtection.get_csrf_token()
  end
end
