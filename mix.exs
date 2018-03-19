defmodule SortingHat.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sorting_hat,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SortingHat, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0-rc"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:short_maps, "~> 0.1.2"},
      {:flow, "~> 0.13"},
      {:mongodb, "~> 0.4.3"},
      {:ex_twilio, github: "danielberkompas/ex_twilio"},
      {:nimble_csv, "~> 0.2.0"},
      {:honeydew, "~> 1.0.4"},
      {:swoosh, "~> 0.13"},
      {:distillery, "~> 1.5", runtime: false}
    ]
  end
end
