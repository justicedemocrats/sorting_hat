defmodule SortingHat.ResultsEmail do
  import Swoosh.Email

  def create(to, s3_paths, cost) when is_binary(to) and is_list(s3_paths) do
    new()
    |> to(to)
    |> from({"JD Sorting Hat", "ben@justicedemocrats.com"})
    |> subject("Your lands vs cell results are ready!")
    |> text_body(body(cost, s3_paths))
  end

  def body(cost, s3_paths) do
    ~s[
Hi friend!

Your lands vs. cell results are ready, and attached.

The total cost for this lookup was #{cost}.
Have a good day!

You can download your files here:
#{Enum.map(s3_paths, &~s[
  #{&1}
]) |> Enum.join("\n")}
]
  end
end
