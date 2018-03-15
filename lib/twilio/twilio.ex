defmodule SortingHat.Twilio do
  require Logger
  import ShortMaps

  def lookup(number) do
    lookup =
      case ExTwilio.Lookup.retrieve(number, type: "carrier") do
        {:ok, result} ->
          twilio_raw = Map.from_struct(result)
          type = result.carrier["type"]
          normalized = result.phone_number
          ~m(type number normalized twilio_raw)

        {:error, error_message, 404} ->
          %{error: error_message}
      end

    lookup
  end
end
