defmodule NumberF.MixProject do
  use Mix.Project

  @version "0.2.0"
  @github_url "https://github.com/jamesnjovu/elixir_number_functions"
  @docs_url "https://hexdocs.pm/number_f"

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
      homepage_url: @docs_url,
      xref: [exclude: [:httpc, :public_key]]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {NumberF.Application, []}
    ]
  end

  defp deps do
    [
      {:decimal, "~> 2.0"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false}
    ]
  end

  # Shown on hex.pm and indexed by Hex search, Google, and LLM crawlers.
  # Lead with the concrete nouns people actually search for.
  defp description do
    """
    Number formatting, currency and financial math for Elixir. Format currency and \
    numbers for 22 locales, convert numbers to words and Roman numerals, calculate \
    compound interest, EMI, VAT and income tax, run statistics, validate credit \
    cards, and convert units. One zero-config dependency.\
    """
  end

  defp package do
    [
      name: "number_f",
      files: ~w(lib guides priv/static/images .formatter.exs mix.exs
                README.md LICENSE CHANGELOG.md CONTRIBUTING.md llms.txt),
      # `mix test.numberf_*` are for developing this library, not for consumers.
      exclude_patterns: ["lib/mix"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @github_url,
        "Documentation" => @docs_url,
        "Changelog" => "#{@github_url}/blob/master/CHANGELOG.md",
        "Cheatsheet" => "#{@docs_url}/cheatsheet.html",
        "llms.txt" => "#{@docs_url}/llms.txt",
        "Issues" => "#{@github_url}/issues"
      },
      maintainers: ["James Njovu"]
    ]
  end

  defp docs do
    [
      main: "readme",
      logo: "priv/static/images/logo.svg",
      favicon: "priv/static/images/favicon.svg",
      canonical: @docs_url,
      language: "en",
      api_reference: true,
      filter_modules: fn module, _ ->
        not match?("Elixir.Mix.Tasks." <> _, Atom.to_string(module))
      end,
      # "markdown" is what emits llms.txt / llms-full.txt for AI assistants.
      formatters: ["html", "markdown"],
      source_ref: "v#{@version}",
      source_url_pattern: "#{@github_url}/blob/v#{@version}/%{path}#L%{line}",
      authors: ["James Njovu"],
      assets: %{"priv/static/images" => "assets"},
      before_closing_head_tag: &before_closing_head_tag/1,
      extras: [
        "README.md": [title: "Overview"],
        "guides/getting-started.md": [title: "Getting Started"],
        "guides/cheatsheet.cheatmd": [title: "Cheatsheet"],
        "guides/currency-formatting.md": [title: "Currency Formatting"],
        "guides/financial-calculations.md": [title: "Financial Calculations"],
        "guides/internationalization.md": [title: "Internationalization"],
        "guides/faq.md": [title: "FAQ"],
        "CHANGELOG.md": [title: "Changelog"],
        "CONTRIBUTING.md": [title: "Contributing"]
      ],
      groups_for_extras: [
        Guides: [
          "guides/getting-started.md",
          "guides/cheatsheet.cheatmd",
          "guides/currency-formatting.md",
          "guides/financial-calculations.md",
          "guides/internationalization.md",
          "guides/faq.md"
        ],
        Other: ["CHANGELOG.md", "CONTRIBUTING.md"]
      ],
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
          NumberF.Formatter,
          NumberF.CustomFormatter,
          NumberF.Currencies
        ],
        "Conversion Modules": [
          NumberF.Metrics
        ],
        "Validation & Utilities": [
          NumberF.Validation
        ],
        "Date Handling": [
          NumberF.DateCalculations
        ],
        Internationalization: [
          NumberF.I18n
        ]
      ],
      nest_modules_by_prefix: [
        NumberF
      ],
      skip_undefined_reference_warnings_on: [
        "CHANGELOG.md"
      ],
      # Internal modules deliberately named in the docs as "not public API".
      skip_code_autolink_to: [
        "NumberF.Currency",
        "NumberF.Memory",
        "NumberF.Randomizer",
        "NumberF.Helper",
        "NumberF.NumbersToWords",
        "NumberF.NumberToWord"
      ]
    ]
  end

  # Static metadata in <head>. Emitted server-side so crawlers and LLM
  # fetchers that do not execute JavaScript still see it.
  defp before_closing_head_tag(:html) do
    """
    <meta name="description" content="NumberF is an Elixir library for number formatting, currency formatting across 22 locales, number-to-words conversion, financial calculations (compound interest, EMI, amortization), tax calculations (VAT, income tax), statistics, and unit conversion.">
    <meta property="og:type" content="website">
    <meta property="og:site_name" content="NumberF">
    <meta property="og:title" content="NumberF — Number formatting, currency and financial math for Elixir">
    <meta property="og:description" content="Format currency for 22 locales, convert numbers to words, calculate interest, EMI, VAT and tax, and run statistics in Elixir.">
    <meta property="og:url" content="#{@docs_url}">
    <meta property="og:image" content="#{@docs_url}/assets/logo.svg">
    <meta name="twitter:card" content="summary">
    <meta name="twitter:title" content="NumberF — Elixir number, currency and finance library">
    <meta name="twitter:description" content="Format currency for 22 locales, convert numbers to words, calculate interest, EMI, VAT and tax, and run statistics in Elixir.">
    <link rel="alternate" type="text/plain" href="#{@docs_url}/llms.txt" title="llms.txt">
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "SoftwareSourceCode",
      "name": "NumberF",
      "alternateName": "number_f",
      "description": "An Elixir library for number formatting, currency formatting, number-to-words conversion, financial and tax calculations, statistics, validation and unit conversion.",
      "codeRepository": "#{@github_url}",
      "url": "#{@docs_url}",
      "programmingLanguage": {"@type": "ComputerLanguage", "name": "Elixir"},
      "runtimePlatform": "Erlang/OTP",
      "softwareVersion": "#{@version}",
      "license": "https://opensource.org/licenses/MIT",
      "author": {"@type": "Person", "name": "James Njovu"},
      "keywords": "elixir, hex package, number formatting, currency formatting, number to words, roman numerals, ordinals, compound interest, EMI, loan amortization, VAT, income tax, statistics, standard deviation, unit conversion, internationalization, i18n, locale, credit card validation, luhn, byte size, humanize"
    }
    </script>
    """
  end

  defp before_closing_head_tag(_), do: ""
end
