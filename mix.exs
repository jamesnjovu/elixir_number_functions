defmodule NumberF.MixProject do
  use Mix.Project
  @version "0.1.5"

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
      {:decimal, "~> 2.0"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
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
          NumberF,
          NumberF.Registry
        ],
        "Calculation Modules": [
          NumberF.Calculations,
          NumberF.Financial,
          NumberF.Statistics,
          NumberF.Precision,
          NumberF.Tax
        ],
        "Formatting Modules": [
          NumberF.Currency,
          NumberF.Formatter,
          NumberF.CustomFormatter,
          NumberF.Currencies
        ],
        "Conversion Modules": [
          NumberF.Metrics,
          NumberF.NumbersToWords,
          NumberF.NumberToWord
        ],
        "Validation & Utilities": [
          NumberF.Validation,
          NumberF.Memory,
          NumberF.Randomizer,
          NumberF.Helper
        ],
        "Date Handling": [
          NumberF.DateCalculations
        ],
        "Internationalization": [
          NumberF.I18n
        ],
        "Application": [
          NumberF.Application
        ]
      ],
      nest_modules_by_prefix: [
        NumberF
      ]
    ]
  end
end
