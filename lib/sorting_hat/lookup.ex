defmodule SortingHat.Lookup do
  alias SortingHat.{Db}
  import ShortMaps

  @service SortingHat.Twilio

  def lookup(phone) when is_binary(phone) do
    case Db.cached_result(phone) do
      nil ->
        result = @service.lookup(phone)
        {Db.upsert(phone, result), 1}

      result ->
        {result, 0}
    end
  end

  def lookup(phones) when is_list(phones) do
    {not_found, results} = Db.cached_result(phones)

    lookup_count = length(not_found)

    lookups =
      Enum.map(not_found, fn number ->
        Task.async(fn ->
          ~m(type) = result = @service.lookup(number)
          Db.upsert(number, result)
          {number, type}
        end)
      end)
      |> Enum.map(&Task.await/1)
      |> Enum.into(%{})

    {Map.merge(results, lookups), lookup_count}
  end
end
