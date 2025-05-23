defmodule NumberF.MixProject do
  use Mix.Project

  @version "0.1.7"
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
    A comprehensive Elixir library for number formatting, calculation, and internationalization.
    Features include currency formatting, number-to-word conversion, financial calculations,
    statistics, unit conversion, and tax calculations.
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
      main: "readme",
      logo: "priv/static/images/logo.svg",
      extras: [
        "README.md": [title: "Overview"],
        "guides/getting-started.md": [title: "Getting Started"],
        "guides/currency-formatting.md": [title: "Currency Formatting"],
        "guides/financial-calculations.md": [title: "Financial Calculations"],
        "guides/internationalization.md": [title: "Internationalization"],
        "CHANGELOG.md": [title: "Changelog"],
        "CONTRIBUTING.md": [title: "Contributing"]
      ],
      groups_for_extras: [
        Guides: Path.wildcard("guides/*.md"),
        Other: ["CHANGELOG.md", "CONTRIBUTING.md"]
      ],
      authors: ["James Njovu"],
      formatters: ["html"],
      source_ref: "v#{@version}",
      assets: "priv/static/images",
      before_closing_body_tag: &before_closing_body_tag/1,
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

  defp before_closing_body_tag(:html) do
    """
    <script type="text/javascript">
      // Enhance search engine visibility
      document.addEventListener('DOMContentLoaded', function() {
        // Add canonical links
        var link = document.createElement('link');
        link.rel = 'canonical';
        link.href = window.location.href.split('#')[0].split('?')[0];
        document.head.appendChild(link);

        // Add meta description if none exists
        if (!document.querySelector('meta[name="description"]')) {
          var meta = document.createElement('meta');
          meta.name = 'description';
          meta.content = 'NumberF - A comprehensive Elixir library for number formatting, calculation, and manipulation with support for currency formatting, financial calculations, and internationalization.';
          document.head.appendChild(meta);
        }

        // Add schema.org metadata for better search results
        var script = document.createElement('script');
        script.type = 'application/ld+json';
        script.text = JSON.stringify({
          "@context": "https://schema.org",
          "@type": "SoftwareSourceCode",
          "name": "NumberF",
          "description": "Comprehensive Elixir library for number formatting, calculation, and internationalization",
          "programmingLanguage": "Elixir",
          "author": {
            "@type": "Person",
            "name": "James Njovu"
          },
          "keywords": "elixir, number, formatting, currency, financial, calculation, internationalization"
        });
        document.head.appendChild(script);
      });
    </script>
    """
  end

  defp before_closing_body_tag(_), do: ""
end
