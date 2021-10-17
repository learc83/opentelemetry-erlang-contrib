defmodule OpentelemetryFinch.MixProject do
  use Mix.Project

  def project do
    [
      app: :opentelemetry_finch,
      description: description(),
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix],
        plt_core_path: "priv/plts",
        plt_local_path: "priv/plts"
      ],
      deps: deps(),
      name: "Opentelemetry Finch",
      docs: [
        main: "OpentelemetryFinch",
        extras: ["README.md"]
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      source_url:
        "https://github.com/open-telemetry/opentelemetry-erlang-contrib/tree/main/instrumentation/opentelemetry_finch"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  defp description do
    "Trace Finch requests with OpenTelemetry."
  end

  defp package do
    [
      description: "OpenTelemetry tracing for the Finch library",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" =>
          "https://github.com/open-telemetry/opentelemetry-erlang-contrib/instrumentation/opentelemetry_finch",
        "OpenTelemetry Erlang" => "https://github.com/open-telemetry/opentelemetry-erlang",
        "OpenTelemetry Erlang Contrib" => "https://github.com/open-telemetry/opentelemetry-erlang-contrib",
        "OpenTelemetry.io" => "https://opentelemetry.io"
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:opentelemetry_api, "~> 1.0.0-rc.3"},
      {:opentelemetry_telemetry, "~> 1.0.0-beta.4"},
      {:telemetry, "~> 0.4 or ~> 1.0.0"},
      # TODO do we not want this in production?
      {:opentelemetry, "~> 1.0.0-rc.3", only: [:dev, :test]},
      {:opentelemetry_exporter, "~> 1.0.0-rc.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.24", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false}
    ]
  end
end
