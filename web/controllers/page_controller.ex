defmodule SortingHat.PageController do
  use SortingHat.Web, :controller
  import ShortMaps

  def index(conn, _params) do
    queued_jobs = []
    render(conn, "index.html", ~m(queued_jobs)a |> Enum.into([]))
  end

  def queue(conn, ~m(col_num upload email)) do
    ~m(path filename)a = upload["file"]
    Honeydew.async({:process_file, [~m(col_num path filename email)]}, :queue)
    redirect(conn, to: "/?secret=#{conn.assigns.secret}")
  end
end
