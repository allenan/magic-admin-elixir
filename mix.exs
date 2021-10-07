defmodule Magic.MixProject do
  use Mix.Project

  def project do
    [
      app: :magic,
      name: :magic_admin,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/allenan/magic-admin-elixir",
      homepage_url: "https://github.com/allenan/magic-admin-elixir"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:jason, "~> 1.2"},
      {:eth, "~> 0.6.4"}
    ]
  end
end
