defmodule SortingHat.Db do
  import ShortMaps

  def cached_result(number) when is_binary(number) do
    Mongo.find_one(:mongo, "phones", ~m(number)a)
  end

  def cached_result(numbers) when is_list(numbers) do
    results =
      Mongo.find(:mongo, "phones", %{"number" => %{"$in" => numbers}})
      |> Enum.to_list()
      |> Enum.map(fn ~m(number type) ->
        {number, type}
      end)
      |> Enum.into(%{})

    found_numbers = Map.keys(results) |> MapSet.new()
    not_found = MapSet.new(numbers) |> MapSet.difference(found_numbers) |> MapSet.to_list()
    {not_found, results}
  end

  def upsert(number, result) do
    Mongo.update_one(:mongo, "phones", ~m(number)a, %{"$set" => result}, upsert: true)
  end
end
