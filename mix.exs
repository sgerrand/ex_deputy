defmodule Deputy.MixProject do
  use Mix.Project

  @source_url "https://github.com/sgerrand/ex_deputy"
  @version "0.0.0-dev"

  def project do
    [
      app: :deputy,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Hex
      package: package(),
      description: "Elixir client for the Deputy API",

      # Docs
      name: "Deputy",
      homepage_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:expublish, "~> 2.5", only: :dev, runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      maintainers: ["Sasha Gerrand"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Sponsor" => "https://github.com/sponsors/sgerrand"
      },
      files: ~w(lib LICENSE mix.exs README.md)
    ]
  end
end
