defmodule SortingHat.PageController do
  use SortingHat.Web, :controller
  import ShortMaps

  def index(conn, _params) do
    {{waiting, up_next}, _running} = Honeydew.state(:queue) |> List.first() |> Map.get(:private)

    running =
      Honeydew.status(:queue)
      |> Map.get(:workers)
      |> Map.values()
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(fn worker ->
        {task, status} = worker
        %{task: extract_task(task), status: extract_status(status)}
      end)

    queued =
      Enum.concat(
        running,
        Enum.concat(waiting, up_next)
        |> Enum.map(fn job ->
          %{task: extract_task(job), status: %{status: "waiting", progress: 0}}
        end)
      )

    render(conn, "index.html", ~m(queued)a)
  end

  def queue(conn, ~m(col_num upload email)) do
    ~m(path filename)a = upload["file"]
    new_path = "./input-files/filename-#{DateTime.utc_now() |> DateTime.to_unix()}"
    File.rename(path, new_path)
    path = new_path
    Honeydew.async({:process_file, [~m(col_num path filename email)]}, :queue)
    redirect(conn, to: "/?secret=#{conn.assigns.secret}")
  end

  def extract_task(%{task: {_, [task]}}) do
    ~m(filename email) = task
    ~m(filename email)a
  end

  def extract_status({status, progress}) do
    status = Atom.to_string(status)
    ~m(status progress)a
  end
end
