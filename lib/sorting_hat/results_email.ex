defmodule SortingHat.ResultsEmail do
  import Swoosh.Email

  def create(to, s3_paths, cost, counts) when is_binary(to) and is_list(s3_paths) do
    new()
    |> to(to)
    |> from({"JD Sorting Hat", "ben@justicedemocrats.com"})
    |> subject("Your lands vs cell results are ready!")
    |> text_body(body(cost, s3_paths, counts))
  end

  def body(cost, s3_paths, counts) do
    ~s[
Hi friend!

Your lands vs. cell results are ready, and attached.

The total cost for this lookup was #{cost}.

Here's the quick overview:
#{Enum.map(counts, fn {type, count} -> ~s[\t#{type} -> #{count}] end) |> Enum.join("\n")}

Have a good day!

You can download your files here:
#{Enum.map(s3_paths, &~s[
  #{&1}
]) |> Enum.join("\n")}
]
  end
end
