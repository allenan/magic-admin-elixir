defmodule Magic.MixProject do
  use Mix.Project

  def project do
    [
      app: :magic,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
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

  defp description() do
    "Magic admin Elixir SDK makes it easy to leverage Decentralized ID tokens to protect routes and restricted resources for your application."
  end

  defp package() do
    [
      name: "magic_admin",
      # These are the default files included in the package
      files: ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
                license* CHANGELOG* changelog* src),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/allenan/magic-admin-elixir"}
    ]
  end
end
