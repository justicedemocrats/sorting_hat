defmodule SortingHat.Accountant do
  use Agent

  def start_link do
    Agent.start_link(fn -> 0 end)
  end

  def add_n_lookups(pid, n \\ 1, cents \\ 0.5) do
    Agent.update(pid, fn current_cost -> current_cost + n * cents end)
  end

  def get_cost(pid) do
    Agent.get(pid, & &1)
  end
end
