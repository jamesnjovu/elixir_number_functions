<p align="center">
  <img src="https://raw.githubusercontent.com/jamesnjovu/elixir_number_functions/master/priv/static/images/logo.svg" alt="NumberF logo" width="120" height="120">
</p>

<h1 align="center">NumberF</h1>

<p align="center">
  <strong>Number formatting, currency, and financial math for Elixir.</strong><br>
  One zero-config dependency for the numeric work every app ends up rewriting.
</p>

<p align="center">
  <a href="https://hex.pm/packages/number_f"><img src="https://img.shields.io/hexpm/v/number_f.svg?style=flat-square" alt="Hex.pm version"></a>
  <a href="https://hexdocs.pm/number_f"><img src="https://img.shields.io/badge/hex-docs-informational.svg?style=flat-square" alt="HexDocs"></a>
  <a href="https://hex.pm/packages/number_f"><img src="https://img.shields.io/hexpm/dt/number_f.svg?style=flat-square" alt="Total downloads"></a>
  <a href="https://github.com/jamesnjovu/elixir_number_functions/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/jamesnjovu/elixir_number_functions/ci.yml?branch=master&style=flat-square" alt="CI status"></a>
  <a href="https://github.com/jamesnjovu/elixir_number_functions/blob/master/LICENSE"><img src="https://img.shields.io/hexpm/l/number_f.svg?style=flat-square" alt="MIT license"></a>
</p>

---

NumberF is an Elixir library that handles the numeric chores that show up in almost
every real application: formatting money, printing amounts in words on an invoice,
working out loan repayments, applying VAT, and displaying numbers the way a user's
locale expects them.

It has one runtime dependency (`decimal`), needs no configuration, and every function
is callable directly off the top-level `NumberF` module.

```elixir
NumberF.currency(1234.567, "USD")                    # => "USD 1,234.57"
NumberF.to_words(42.75, "Dollars", "Cents")          # => "Forty Two Dollars And Seventy Five Cents"
NumberF.format_currency(1234.56, "fr-FR")            # => "1 234,56 €"
NumberF.calculate_emi(100_000, 0.10, 12)             # => 8791.59
NumberF.calculate_vat(100, 0.2)                      # => %{net: 100.0, vat: 20.0, gross: 120.0}
NumberF.standard_deviation([2, 4, 4, 4, 5, 5, 7, 9]) # => 2.0
```

## Installation

Add `number_f` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:number_f, "~> 0.4.0"}
  ]
end
```

Then fetch it:

```bash
mix deps.get
```

Requires Elixir 1.14 or later. No application configuration is needed.

## What it does

| Area | Functions | Example |
|---|---|---|
| **Currency formatting** | `currency/3`, `comma_separated/2`, `number_to_delimited/2` | `NumberF.currency(1234.5)` → `"ZMW 1,234.50"` |
| **Numbers to words** | `to_words/3`, `spell_number/2` (en/fr/es/de), `ordinal/1`, Roman numerals | `NumberF.to_roman(1999)` → `"MCMXCIX"` |
| **Financial math** | interest, `amortization_schedule/3`, `npv/2`, `irr/2`, `present_value/3`, `cagr/3`, annuities, depreciation, `payback_period/2` | `NumberF.npv(0.1, flows)` → `388.77` |
| **Tax** | `calculate_vat/3`, `calculate_sales_tax/3`, `NumberF.Tax.calculate_income_tax/2` | `NumberF.calculate_vat(100, 0.2)` |
| **Statistics** | mean/median/mode, population **and** sample variance, `percentile/2`, `quartiles/1`, `correlation/2`, `linear_regression/2`, `summary/1`, `outliers/2` | `NumberF.percentile(data, 25)` → `3.25` |
| **Internationalization** | `format_number/2`, `format_currency/3` across 22 locales | `NumberF.format_number(1234567.89, "de-DE")` |
| **Unit conversion** | metric ↔ imperial, temperature, arbitrary unit tables | `NumberF.celsius_to_fahrenheit(25)` → `77.0` |
| **Validation** | IBAN, ISBN, EAN/UPC, IMEI, ABA routing, Luhn + `card_brand/1` | `NumberF.valid_iban?("GB82 WEST…")` → `true` |
| **Precision** | `clamp/3`, `safe_divide/3`, bankers rounding, half-away-from-zero, float comparison | `NumberF.clamp(15, 0, 10)` → `10` |
| **Dates** | age, business days (forward and back), quarters, fiscal years, ISO weeks | `NumberF.quarter(~D[2024-08-22])` → `3` |
| **Humanizing** | `format_bytes/2` (SI and binary), `format_duration/2`, `pluralize/3`, `accounting_format/2`, phone numbers | `NumberF.format_duration(3725)` → `"1h 2m 5s"` |

Plus number theory and base conversion: `fibonacci/1`, `prime_factors/1`, `divisors/1`,
`digital_root/1`, `to_base/2` and `from_base/2` for any base from 2 to 36.

**260+ functions, all reachable from the single `NumberF` module**, grouped in the docs
by area. Full API reference: **[hexdocs.pm/number_f](https://hexdocs.pm/number_f)**

## Common tasks

<details>
<summary><strong>How do I format a number as currency in Elixir?</strong></summary>

```elixir
NumberF.currency(1234.567)             # => "ZMW 1,234.57"  (default unit)
NumberF.currency(1234.567, "USD")      # => "USD 1,234.57"
NumberF.currency(1234.567, "USD", 0)   # => "USD 1,235"

# Locale-aware, with the correct symbol and placement:
NumberF.format_currency(1234.56, "en-US")   # => "$1,234.56"
NumberF.format_currency(1234.56, "fr-FR")   # => "1 234,56 €"
NumberF.format_currency(1234.56, "de-DE")   # => "1.234,56 €"
```

See the [Currency Formatting guide](https://hexdocs.pm/number_f/currency-formatting.html).
</details>

<details>
<summary><strong>How do I convert a number to words for an invoice or cheque?</strong></summary>

```elixir
NumberF.to_words(42)                          # => "Forty Two Kwacha"
NumberF.to_words(42.75, "Dollars", "Cents")   # => "Forty Two Dollars And Seventy Five Cents"
NumberF.spell_number(42, "fr")                # => "Quarante-deux"
```
</details>

<details>
<summary><strong>How do I calculate a loan repayment (EMI) or compound interest?</strong></summary>

```elixir
NumberF.simple_interest(1000, 0.05, 2)        # => 100.0
NumberF.compound_interest(1000, 0.05, 2)      # => 102.5
NumberF.compound_interest(1000, 0.05, 2, 12)  # => 104.94   (monthly compounding)
NumberF.calculate_emi(100_000, 0.10, 12)      # => 8791.59  (principal, annual rate, months)
```

See the [Financial Calculations guide](https://hexdocs.pm/number_f/financial-calculations.html).
</details>

<details>
<summary><strong>How do I add or remove VAT / sales tax?</strong></summary>

```elixir
NumberF.calculate_vat(100, 0.2)                # => %{net: 100.0, vat: 20.0, gross: 120.0}
NumberF.calculate_vat(120, 0.2, true)          # VAT-inclusive: extracts the tax from the gross
NumberF.Tax.calculate_income_tax(75_000, brackets)
# => %{tax: 12248.5, effective_rate: 0.1633}   (progressive brackets)
```
</details>

<details>
<summary><strong>How do I format numbers for a different locale?</strong></summary>

```elixir
NumberF.format_number(1234567.89, "en-US")   # => "1,234,567.89"
NumberF.format_number(1234567.89, "fr-FR")   # => "1 234 567,89"
NumberF.format_number(1234567.89, "de-DE")   # => "1.234.567,89"
```

See the [Internationalization guide](https://hexdocs.pm/number_f/internationalization.html).
</details>

## How it compares

NumberF is a **breadth-first utility belt**, not a specialist library. Reach for it when
you want one small dependency covering many numeric needs; reach elsewhere when you need
depth in a single area:

- **[ex_cldr](https://hex.pm/packages/ex_cldr)** — full Unicode CLDR data, the right choice
  when locale correctness across hundreds of locales is a hard requirement.
- **[money](https://hex.pm/packages/money) / [ex_money](https://hex.pm/packages/ex_money)** —
  a dedicated `Money` type with currency-safe arithmetic. Use these if money is a first-class
  domain type in your system.
- **[number](https://hex.pm/packages/number)** — a focused port of Rails' number helpers.

NumberF overlaps with all three at the edges, but bundles formatting, finance, tax,
statistics, validation, and unit conversion behind a single flat API.

## Documentation

- [Getting Started](https://hexdocs.pm/number_f/getting-started.html)
- [Cheatsheet](https://hexdocs.pm/number_f/cheatsheet.html) — every function on one page
- [Currency Formatting](https://hexdocs.pm/number_f/currency-formatting.html)
- [Financial Calculations](https://hexdocs.pm/number_f/financial-calculations.html)
- [Internationalization](https://hexdocs.pm/number_f/internationalization.html)
- [FAQ](https://hexdocs.pm/number_f/faq.html)
- [Changelog](https://github.com/jamesnjovu/elixir_number_functions/blob/master/CHANGELOG.md)

### For AI assistants and LLM tooling

The documentation is published in an LLM-readable form at
[`hexdocs.pm/number_f/llms.txt`](https://hexdocs.pm/number_f/llms.txt), following the
[llms.txt convention](https://llmstxt.org). Point Claude, ChatGPT, Cursor, or any
retrieval tool at that URL for a complete, plain-text API reference. A condensed
[`llms.txt`](https://github.com/jamesnjovu/elixir_number_functions/blob/master/llms.txt)
also lives at the root of this repository.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](https://github.com/jamesnjovu/elixir_number_functions/blob/master/CONTRIBUTING.md) for
the development workflow, and [SECURITY.md](https://github.com/jamesnjovu/elixir_number_functions/blob/master/SECURITY.md)
for reporting vulnerabilities.

```bash
git clone https://github.com/jamesnjovu/elixir_number_functions.git
cd elixir_number_functions
mix deps.get
mix test
```

## License

Released under the [MIT License](https://github.com/jamesnjovu/elixir_number_functions/blob/master/LICENSE). Copyright © 2024-2026 James Njovu.
