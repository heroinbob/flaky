defmodule Flaky.MixProject do
  use Mix.Project

  def project do
    [
      app: :flaky,
      deps: deps(),
      elixir: "~> 1.14",
      escript: [main_module: Flaky.CLI],
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp deps do
    [
      {:credo, "~> 1.7.3", runtime: false},
      {:dialyxir, "~> 1.4.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
