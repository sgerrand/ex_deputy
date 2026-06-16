defmodule Deputy.MixProject do
  use Mix.Project

  @source_url "https://github.com/sgerrand/ex_deputy"
  @version "0.5.0"

  def project do
    [
      app: :deputy,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_local_path: "priv/plts",
        plt_core_path: "priv/plts"
      ],
      test_coverage: [tool: ExCoveralls, test_task: "test"],

      # Hex
      package: package(),
      description: "Elixir client for the Deputy API",

      # Docs
      name: "Deputy",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs()
    ]
  end

  def cli do
    [preferred_envs: ["coveralls.lcov": :test]]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:req, "~> 0.6.1"},
      {:telemetry, "~> 1.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:expublish, "~> 2.5", only: :dev, runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:plug, "~> 1.0", only: :test},
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end

  defp package do
    [
      maintainers: ["Sasha Gerrand"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "https://hexdocs.pm/deputy/changelog.html",
        "Sponsor" => "https://github.com/sponsors/sgerrand"
      },
      files: ~w(lib LICENSE mix.exs README.md)
    ]
  end
end
