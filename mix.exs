defmodule NumberF.MixProject do
  use Mix.Project

  def project do
    [
      app: :number_f,
      version: "0.1.2",
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
      logo: "path/to/logo.png", # Add a logo image if available
      extras: ["README.md", "LICENSE"],
      authors: ["James Njovu"],
      formatters: ["html"],
      source_ref: "v0.1.1",
      groups_for_modules: [
        "Core Functions": [
          NumberF
        ],
        "Internal Modules": [
          NumberF.Currency,
          NumberF.Memory,
          NumberF.Randomizer,
          NumberF.NumbersToWords,
          NumberF.NumberToWord,
          NumberF.Helper
        ],
        "Application": [
          NumberF.Application
        ]
      ],
      groups_for_functions: [
        "Formatting": [
          :currency,
          :comma_separated,
          :number_to_delimited
        ],
        "Conversion": [
          :to_words,
          :to_int,
          :to_float,
          :to_decimal,
          :to_boolean
        ],
        "Generation": [
          :randomizer,
          :default_password
        ],
        "Utilities": [
          :memory_size_cal,
          :sum_decimal
        ]
      ]
    ]
  end
end
