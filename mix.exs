defmodule NumberF.MixProject do
  use Mix.Project

  @version "0.4.0"
  @github_url "https://github.com/jamesnjovu/elixir_number_functions"
  @docs_url "https://hexdocs.pm/number_f"

  def project do
    [
      app: :number_f,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      name: "NumberF",
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @github_url,
      homepage_url: @docs_url,
      xref: [exclude: [:httpc, :public_key]],
      test_coverage: [tool: ExCoveralls],
      # Ratcheted deliberately: the real figure today is ~76%. Raise this as each
      # phase adds tests, so coverage can never silently regress.
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.github": :test
      ],
      dialyzer: [
        plt_add_apps: [:mix, :ex_unit],
        # Per-env PLT: the dev and test dependency sets differ, and one shared file
        # goes stale the moment the environment changes.
        plt_file: {:no_warn, "priv/plts/dialyzer-#{Mix.env()}.plt"}
      ]
    ]
  end

  # A pure computation library needs no supervision tree. There is deliberately no
  # `mod:` key: NumberF.Application was an empty supervisor whose only effect was to
  # make `Supervisor.start_link/2` return {:error, {:already_started, _}} in tests.
  # :crypto ships with OTP, so it adds no Hex dependency; generate_password/1 needs
  # it because :rand is not a secure source of randomness for passwords.
  def application do
    [extra_applications: [:logger, :crypto]]
  end

  # test/support holds shared test helpers; consumers always build in :prod.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # The only runtime dependency, and deliberately so — "one zero-config
      # dependency" is a stated selling point. `~> 3.0` is allowed so consumers can
      # take the fix for GHSA-rhv4-8758-jx7v (unbounded exponent DoS, decimal < 3.0.0).
      # Only new/to_float/from_float/to_string/round/add are used, all stable across
      # both majors; the full suite is verified green against 2.3.0 and 3.1.1.
      # Note this needs jason >= 1.4.5 in the dev/test closure — 1.4.4 declared
      # `decimal ~> 1.0 or ~> 2.0` and held the whole resolution below 3.
      {:decimal, "~> 2.0 or ~> 3.0"},

      # Tooling. :test as well as :dev for credo/dialyxir — the CI lint job runs with
      # MIX_ENV=test, where a dev-only dep makes `mix credo` an unknown task.
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test, runtime: false},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      # One command for everything CI's lint job gates on, so a local run and a CI
      # run cannot disagree about whether the tree is clean.
      lint: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "credo --strict"
      ]
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
      # Generated from the `@doc group:` metadata on each delegation, so the sidebar
      # cannot drift from the code. With 261 function arities on one module, an
      # ungrouped page is a wall of names for a reader and one undifferentiated
      # chunk for anything indexing it.
      groups_for_docs: [
        Formatting: &(&1[:group] == "Formatting"),
        Currency: &(&1[:group] == "Currency"),
        Text: &(&1[:group] == "Text"),
        Financial: &(&1[:group] == "Financial"),
        Tax: &(&1[:group] == "Tax"),
        Statistics: &(&1[:group] == "Statistics"),
        Precision: &(&1[:group] == "Precision"),
        Validation: &(&1[:group] == "Validation"),
        Math: &(&1[:group] == "Math"),
        Units: &(&1[:group] == "Units"),
        Dates: &(&1[:group] == "Dates"),
        Humanize: &(&1[:group] == "Humanize"),
        Internationalization: &(&1[:group] == "Internationalization"),
        Introspection: &(&1[:group] == "Introspection")
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
          NumberF.Validation,
          NumberF.Password
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
