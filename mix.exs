defmodule Magic.MixProject do
  use Mix.Project

  def project do
    [
      app: :magic_admin,
      version: "0.5.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
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
      {:ex_sha3, "~> 0.1.1"},
      {:ex_secp256k1, "~> 0.5"},
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"}
    ]
  end

  defp description() do
    "Magic admin Elixir SDK makes it easy to leverage Decentralized ID tokens to protect routes and restricted resources for your application."
  end

  defp package() do
    [
      name: "magic_admin",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/allenan/magic-admin-elixir"}
    ]
  end

  defp docs() do
    [
      extras: ["README.md"],
      main: "readme"
    ]
  end
end
