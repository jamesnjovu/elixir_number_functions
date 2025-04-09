defmodule NumberF.MixProject do
  use Mix.Project
  @version "0.1.3"

  def project do
    [
      app: :number_f,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "NumberF",
      source_url: "https://github.com/jamesnjovu/elixir_number_functions",
      description: "Comprehensive utility library for number formatting, conversion, and manipulation in Elixir",
      docs: docs(),
      package: package(),
      xref: [exclude: [:httpc, :public_key]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NumberF.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:number, "~> 1.0.1"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end


  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/jamesnjovu/elixir_number_functions",
        "Docs" => "https://hexdocs.pm/number_f"
      },
      maintainers: ["James Njovu"],
      description: """
      NumberF provides utility functions for number formatting (currency, delimiters),
      conversion (to words, to different numeric types), random string generation,
      memory size humanization, and more.
      """
    ]
  end

  defp docs do
    [
      main: "NumberF",
      # logo: "path/to/logo.png",
      extras: ["README.md", "LICENSE"],
      authors: ["James Njovu"],
      formatters: ["html"],
      source_ref: "v#{@version}",
      groups_for_modules: [
        "Core Functions": [
          NumberF
        ],
        "Calculation Modules": [
          NumberF.Calculations,
          NumberF.Financial,
          NumberF.Statistics
        ],
        "Formatting Modules": [
          NumberF.Currency,
          NumberF.Formatter
        ],
        "Validation & Utilities": [
          NumberF.Validation,
          NumberF.Memory,
          NumberF.Randomizer
        ],
        "Text Conversion": [
          NumberF.NumbersToWords,
          NumberF.NumberToWord,
          NumberF.Helper
        ],
        "Date Handling": [
          NumberF.DateCalculations
        ],
        "Application": [
          NumberF.Application
        ]
      ],
    ]
  end
end
