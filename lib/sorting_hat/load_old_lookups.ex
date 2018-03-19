defmodule SortingHat.LoadOldLookups do
  alias NimbleCSV.RFC4180, as: CSV
  require Logger
  import ShortMaps

  @logging_interval 100
  @insert_size 100

  def go do
    File.stream!("./phone_numbers.csv")
    |> CSV.parse_stream()
    |> Stream.chunk_every(@insert_size)
    |> Stream.with_index()
    |> Stream.map(&log/1)
    |> Stream.map(fn chunk ->
      Enum.filter(chunk, &is_valid?/1)
      |> Enum.map(&format_from_row/1)
      |> Enum.filter(&is_not_error/1)
      |> Enum.map(&format_for_db/1)
      |> write_to_mongo()
    end)
    |> Stream.run()

    # |> Flow.filter(&is_valid?/1)
    # |> Flow.map(&format_from_row/1)
    # |> Flow.filter(&is_not_error/1)
    # |> Flow.map(&format_for_db/1)
    # |> Flow.each(&write_to_mongo/1)
    # |> Flow.into_stages(timeout: 10_000)
  end

  def log({row, idx}) do
    if rem(idx, @logging_interval) == 0 do
      Logger.info("Done #{idx * @insert_size}")
    end

    row
  end

  def is_valid?(row) do
    twilio_result = List.last(row)

    case Poison.decode(twilio_result) do
      {:ok, _} ->
        true

      _ ->
        false
    end
  end

  def format_from_row(row) do
    input_number = Enum.at(row, 2)
    twilio_result = List.last(row) |> Poison.decode!()
    number = SortingHat.Lookup.easy_normalize(input_number)
    ~m(number twilio_result)
  end

  def is_not_error(~m(twilio_result)) do
    not Map.has_key?(twilio_result, "error")
  end

  def format_for_db(~m(number twilio_result)) do
    normalized = twilio_result["phone_number"]
    twilio_raw = twilio_result
    type = get_in(twilio_result, ~w(carrier type))
    ~m(number normalized twilio_raw type)
  end

  def write_to_mongo(json = ~m(number)) do
    SortingHat.Db.upsert(number, json)
    # json
  end

  def write_to_mongo([]) do
    :ok
  end

  def write_to_mongo(jsons) when is_list(jsons) do
    SortingHat.Db.replace_many(jsons)
  end
end
