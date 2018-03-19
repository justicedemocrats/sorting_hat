defmodule SortingHat.Worker do
  use Honeydew.Progress
  alias NimbleCSV.RFC4180, as: CSV
  alias SortingHat.Accountant
  import ShortMaps

  @behaviour Honeydew.Worker
  # @batch_size 100
  @batch_size 1

  def process_file(~m(path filename email col_num)) do
    File.mkdir_p("./files")

    without_type =
      String.split(filename, ".")
      |> Enum.reverse()
      |> Enum.slice(1..100)
      |> Enum.reverse()
      |> Enum.join(".")

    files =
      Enum.map(~w(mobile landline other processed), fn type ->
        new_path = "./output-files/#{without_type}-#{type}.csv"
        {:ok, file} = File.open(new_path, [:write])
        {type, ~m(path file new_path)}
      end)
      |> Enum.into(%{})

    {:ok, accountant} = Accountant.start_link()

    File.stream!(path)
    |> CSV.parse_stream()
    |> Stream.chunk_every(@batch_size)
    |> Stream.with_index()
    |> Stream.map(&update_progress/1)
    |> Stream.map(&process_chunk(&1, col_num, files, accountant))
    |> Stream.run()

    attachment_paths = Map.values(files) |> Enum.map(& &1["new_path"])
    cost = Accountant.get_cost(accountant)

    SortingHat.ResultsEmail.create(email, attachment_paths, cost)
    |> SortingHat.Mailer.deliver()
  end

  def update_progress({chunk, idx}) do
    progress(idx)
    chunk
  end

  def process_chunk(chunk, col_num_string, files, accountant) do
    :timer.sleep(30_000)
    {col_num, _} = Integer.parse(col_num_string)
    IO.inspect(List.first(chunk))
    IO.inspect(col_num - 1)
    IO.inspect(Enum.at(List.first(chunk), col_num - 1))
    rows_by_phone = Enum.map(chunk, &{Enum.at(&1, col_num - 1), &1}) |> Enum.into(%{})
    phones = Map.keys(rows_by_phone)
    {results, lookup_count} = SortingHat.Lookup.lookup(phones)

    Accountant.add_n_lookups(accountant, lookup_count)

    Enum.each(phones, fn number ->
      type = Map.get(results, number)
      type_file = get_in(files, [type, "file"])
      processed_file = get_in(files, ~w(processed file))
      row = Map.get(rows_by_phone, number)

      IO.inspect(row)
      row_string = CSV.dump_to_iodata([row]) |> IO.iodata_to_binary()

      processed_row_string =
        [Enum.concat(row, [type])] |> CSV.dump_to_iodata() |> IO.iodata_to_binary()

      IO.binwrite(type_file, row_string)
      IO.binwrite(processed_file, processed_row_string)
    end)
  end
end