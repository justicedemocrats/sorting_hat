defmodule SortingHat.Lookup do
  alias SortingHat.{Db}
  import ShortMaps

  @service SortingHat.Twilio

  def lookup(unnormalized_phone) when is_binary(unnormalized_phone) do
    try do
      phone = easy_normalize(unnormalized_phone)

      case Db.cached_result(phone) do
        nil ->
          result = @service.lookup(phone)
          {Db.upsert(phone, result), 1}

        result ->
          {result["type"], 0}
      end
    rescue
      e ->
        {"not found", 1}
    end
  end

  def lookup(unnormalized_phones) when is_list(unnormalized_phones) do
    phones = Enum.map(unnormalized_phones, &easy_normalize/1)
    {not_found, results} = Db.cached_result(phones)

    lookup_count = length(not_found)

    lookups =
      Enum.map(not_found, fn number ->
        Task.async(fn ->
          try do
            ~m(type) = result = @service.lookup(number)
            Db.upsert(number, result)
            {number, type}
          rescue
            e -> {number, "unknown"}
          end
        end)
      end)
      |> Enum.map(&Task.await/1)
      |> Enum.into(%{})

    {Map.merge(results, lookups), lookup_count}
  end

  def easy_normalize(number) do
    number
    |> String.replace(" ", "", global: true)
    |> String.replace("-", "", global: true)
    |> String.replace("(", "", global: true)
    |> String.replace(")", "", global: true)
  end
end
