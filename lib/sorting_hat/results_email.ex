defmodule SortingHat.ResultsEmail do
  import Swoosh.Email

  def create(to, attachment_paths, cost) when is_binary(to) and is_list(attachment_paths) do
    mail =
      new()
      |> to(to)
      |> from({"JD Sorting Hat", "ben@justicedemocrats.com"})
      |> subject("Your lands vs cell results are ready!")
      |> text_body(body(cost))

    Enum.reduce(attachment_paths, mail, fn path, prev_mail ->
      attachment(prev_mail, path)
    end)
  end

  def body(cost) do
    ~s[
Hi friend!

Your lands vs. cell results are ready, and attached.

The total cost for this lookup was #{cost}.
Have a good day!
]
  end
end
