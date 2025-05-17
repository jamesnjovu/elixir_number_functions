defmodule NumberF.MixProject do
  use Mix.Project

  @version "0.1.5"
  @github_url "https://github.com/jamesnjovu/elixir_number_functions"

  def project do
    [
      app: :number_f,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "NumberF",
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @github_url,
      homepage_url: "https://hexdocs.pm/number_f",
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

  defp description do
    """
    NumberF is a comprehensive utility library for number formatting, calculation, and manipulation
    in Elixir applications. It provides advanced currency formatting, number-to-word conversion,
    financial calculations, statistics, unit conversion, tax calculations, internationalization,
    and much more. Perfect for finance, e-commerce, data analysis, and any application that needs
    sophisticated number handling.
    """
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @github_url,
        "Documentation" => "https://hexdocs.pm/number_f",
        "Changelog" => "#{@github_url}/blob/main/CHANGELOG.md"
      },
      maintainers: ["James Njovu"],
      keywords: [
        "number",
        "currency",
        "formatting",
        "finance",
        "calculation",
        "statistics",
        "internationalization",
        "i18n",
        "conversion",
        "tax",
        "precision",
        "mathematics",
        "utilities"
      ]
    ]
  end

  defp docs do
    [
      main: "NumberF",
      logo: "/images/logo.png",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE"
      ],
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
        Internationalization: [
          NumberF.I18n
        ],
        Application: [
          NumberF.Application
        ]
      ],
      nest_modules_by_prefix: [
        NumberF
      ],
      skip_undefined_reference_warnings_on: [
        "CHANGELOG.md"
      ]
    ]
  end
end
