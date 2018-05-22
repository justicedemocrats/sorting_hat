defmodule SortingHat.Worker do
  use Honeydew.Progress
  alias NimbleCSV.RFC4180, as: CSV
  alias SortingHat.Accountant
  import ShortMaps
  import SweetXml
  require Logger

  @behaviour Honeydew.Worker
  @batch_size 100

  def report_complete_webhook, do: Application.get_env(:sorting_hat, :report_complete_webhook)
  def bucket_name, do: Application.get_env(:sorting_hat, :aws_bucket_name)

  def process_file(~m(path filename email col_num)) do
    File.mkdir_p("./files")

    without_type =
      String.split(filename, ".")
      |> Enum.reverse()
      |> Enum.slice(1..100)
      |> Enum.reverse()
      |> Enum.join(".")

    File.mkdir_p("./output-files")

    header_row = extract_header_line(path)

    files =
      Enum.map(~w(mobile landline other processed non_landline), fn type ->
        new_path = "./output-files/#{without_type}-#{type}.csv"
        nice_name = "#{without_type}-#{type}"
        {:ok, file} = File.open(new_path, [:write])

        if type == "processed",
          do: IO.binwrite(file, header_row <> ~s(,"Type"\n)),
          else: IO.binwrite(file, header_row <> ~s(\n))

        {type, ~m(path file new_path nice_name)}
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

    s3_urls =
      Map.values(files)
      |> Enum.map(fn ~m(new_path nice_name) ->
        upload_to_s3(new_path, "#{nice_name}-#{rand_digits()}.csv")
      end)
      |> Enum.map(&List.to_string/1)

    cost = Accountant.get_cost(accountant)

    counts =
      Enum.map(files, fn {key, ~m(new_path)} ->
        {output, _code} = System.cmd("wc", ["-l", new_path])
        [count, _file] = String.split(output)
        {as_int, _} = Integer.parse(count)
        {key, as_int - 1}
      end)
      |> Enum.into(%{})

    SortingHat.ResultsEmail.create(email, s3_urls, cost)
    |> SortingHat.Mailer.deliver()

    body = ~m(cost email filename s3_urls counts) |> IO.inspect()
    HTTPoison.post(report_complete_webhook(), Poison.encode!(body) |> IO.inspect())
  end

  def update_progress({chunk, idx}) do
    progress(idx * @batch_size)
    chunk
  end

  def process_chunk(chunk, col_num_string, files, accountant) do
    {col_num, _} = Integer.parse(col_num_string)

    rows_by_phone =
      Enum.map(chunk, &{SortingHat.Lookup.easy_normalize(Enum.at(&1, col_num - 1)), &1})
      |> Enum.into(%{})

    phones = Map.keys(rows_by_phone)
    {results, lookup_count} = SortingHat.Lookup.lookup(phones)

    Accountant.add_n_lookups(accountant, lookup_count)

    Enum.each(phones, fn number ->
      type = Map.get(results, number)
      type_file = get_in(files, [type, "file"])
      non_landline_file = get_in(files, ~w(non_landline file))
      processed_file = get_in(files, ~w(processed file))
      row = Map.get(rows_by_phone, number)

      Logger.info("Processed: #{number}")
      row_string = CSV.dump_to_iodata([row]) |> IO.iodata_to_binary()

      processed_row_string =
        [Enum.concat(row, [type])] |> CSV.dump_to_iodata() |> IO.iodata_to_binary()

      IO.binwrite(type_file, row_string)
      IO.binwrite(non_landline_file, row_string)
      IO.binwrite(processed_file, processed_row_string)
    end)
  end

  def extract_header_line(file) do
    {:ok, pid} = File.open(file)
    line = IO.binread(pid, :line)
    File.close(pid)
    String.trim(line)
  end

  def upload_to_s3(path, file_name) do
    {:ok, %{body: body}} =
      path
      |> ExAws.S3.Upload.stream_file()
      |> ExAws.S3.upload(bucket_name(), file_name)
      |> ExAws.request()

    body |> xpath(~x"Location/text()")
  end

  def rand_digits do
    1..5
    |> Enum.map(fn _ -> Enum.random(0..9) end)
    |> Enum.join("")
  end
end
