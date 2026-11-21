# Changelog

All notable changes to the NumberF library will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-11-21

### Added

**Passwords**: `generate_password/1`, `is_valid_password?/2` and
`validate_password/2`, all driven by one keyword-list policy: `:min_length`,
`:max_length`, minimum counts of uppercase, lowercase, digits and special
characters, the alphabet specials are drawn from, and whether to leave out the
ambiguous `I l 1 O 0`. Every key is optional; the default is 12 characters with
at least one of each class. `validate_password/2` returns `:ok` or
`{:error, reasons}`, where `reasons` lists every broken rule (`:too_short`,
`:too_few_digits` and so on) in a fixed order, so a form can say what to fix. An
invalid policy raises `ArgumentError` naming the offending key.

Generation draws from `:crypto` rather than `:rand`, and leaves the calling
process's `:rand` seed untouched.

### Changed

- `:crypto` is now listed in `extra_applications`. It ships with OTP, so this adds
  no Hex dependency.

### Deprecated

- `default_password/0`. It always returns one fixed 8-character shape (`Abc@2345`),
  which cannot be fitted to a site's password rules, and it draws from `:rand`,
  which is not a cryptographically secure generator. It still works and returns
  the same shape as before. Use `generate_password/1` instead.

## [0.3.0] - 2026-08-22

Roughly 100 new functions, taking the public API from 103 arities to 261. No
breaking changes: everything in 0.2.0 keeps working.

### Added

**Statistics** (6 functions to 28) — `percentile/2`, `quartiles/1`, `iqr/1`,
`z_score/3`, `z_scores/1`, `correlation/2`, `covariance/2`, `linear_regression/2`,
`weighted_mean/2`, `geometric_mean/1`, `harmonic_mean/1`, `summary/1`,
`moving_average/2`, `cumulative_sum/1`, `normalize/1`, `outliers/2`,
`remove_outliers/2`, `frequency_distribution/1`, `trimmed_mean/2` and
`coefficient_of_variation/1`.

**Financial** (4 to 20) — `present_value/3`, `future_value/3`, `npv/2`, `irr/2`,
`amortization_schedule/3`, `roi/2`, `cagr/3`, `effective_annual_rate/2`,
`loan_payment/3`, the three annuity functions, straight-line and declining-balance
depreciation, `break_even_point/3` and `payback_period/2`.

`amortization_schedule/3` returns a full period-by-period breakdown and closes at
exactly zero — the final period absorbs the rounding, as a lender's schedule does.
`irr/2` solves by bisection and returns `{:error, :no_sign_change}` rather than a
meaningless number when the cash flows never cross zero.

**Validation** (3 to 14) — `valid_iban?/1` (mod-97), `valid_isbn?/1` (10 and 13),
`valid_ean?/1`, `valid_upc?/1`, `card_brand/1`, `luhn_check_digit/1`,
`valid_luhn?/1`, `valid_routing_number?/1`, `valid_imei?/1`,
`valid_currency_code?/1` and `valid_percentage?/1`.

**Math** — `permutations/2`, `fibonacci/1`, `fibonacci_sequence/1`,
`prime_factors/1`, `divisors/1`, `digits/1`, `digit_sum/1`, `digital_root/1`,
`reverse_number/1`, `palindrome?/1`, `perfect_square?/1`, `nth_root/2`,
`log_base/2`, and base conversion in any base from 2 to 36 (`to_base/2`,
`from_base/2` and hex/binary/octal shorthands).

**Precision** — `clamp/3`, `safe_divide/3`, `sign/1`,
`round_half_away_from_zero/2` and `round_half_even/2`.

**Formatting** — `accounting_format/2` (negatives in parentheses),
`format_bytes/2` (SI and binary, up to exabytes), `format_duration/2` (short, long
and clock forms), `significant_figures/2`, `format_significant/2`, `with_sign/2`,
`pad_number/3` and `pluralize/3`.

**Dates** — `quarter/1`, `quarter_start/1`, `quarter_end/1`, `fiscal_year/2`,
`days_in_month/2`, `leap_year?/1`, `week_number/1`, `month_start/1`, `month_end/1`
and `age_in_months/2`.

### Changed

- The generated documentation now groups functions into Formatting, Currency,
  Text, Financial, Tax, Statistics, Precision, Validation, Math, Units, Dates,
  Humanize, Internationalization and Introspection. The grouping is generated from
  `@doc group:` metadata on each function, so the sidebar cannot drift from the code.
- Still exactly one runtime dependency. Every function above is implemented with
  `:math` and the standard library.

### Fixed

- `I18n.spell_number/3` raised `FunctionClauseError` for any value of 1,000,000 or
  more in French, Spanish and German — only the English speller had a millions
  clause. Found by the first tests ever written against those three languages.

## [0.2.0] - 2026-08-22

Documentation, discoverability, engineering hygiene — and 16 correctness fixes.

The public API is source-compatible with 0.1.8 except where noted under
**Behaviour changes**; those are all cases where the previous result was wrong.

### Fixed

Every item below was reproduced against a compiled build before being fixed, and
each has a named regression test in `test/number_f/regressions_test.exs`.

**Silently wrong results**

- `I18n.spell_number/3` destroyed leading zeros in a fraction. `spell_number(1.05, "en")`
  and `spell_number(1.5, "en")` both returned `"One point five"` — `split_number/1`
  ran `String.to_integer("05")`. Fractions are now read digit by digit, so 1.05 is
  `"One point zero five"`. Currency minor units are read positionally, so 42.5 is
  `"forty-two dollars and fifty cents"`, not five.
- `I18n.spell_number/3` silently fell back to English for any unrecognised language,
  so 18 of the 22 advertised locales produced confidently wrong output. It now raises
  `ArgumentError` naming the four languages that work. Added
  `I18n.supported_languages/0` and `NumberF.spelling_languages/0`.
- `I18n.spell_number/3` emitted a double space wherever the conjunction was empty
  (`"One thousand  two hundred"`).
- `abbreviate_number/2` had no tier above billions, so a trillion rendered as
  `"1.5e3B"`. It also never matched a negative number, so `-5000` came back as
  `"-5000"` rather than `"-5.0K"`.
- `memory_size_cal/1` capped at GB (5 TB showed as `"4656.61 GB"`) and routed
  negatives through the bytes branch. Now handles up to PB.
- `Formatter.scientific_notation/2` and `Formatter.engineering_notation/2`
  hardcoded their own doctest input — `if abs(number - 0.000123) < 1.0e-10` returned
  a canned string. The doctests passed while testing nothing. The underlying defect
  was `trunc/1`, which rounds toward zero and so gives the wrong exponent for any
  magnitude below 1; both now use a floored base-10 exponent.
- `Calculations.is_prime?/1`, `factorial/1` — `factorial/1` is now tail-recursive
  and rejects negative input with `ArgumentError` instead of recursing forever.
- `Randomizer.randomizer/2` with `:alpha` returned letters *and* digits, making it
  identical to the catch-all. The one option documented as letters-only never worked.
- `DateCalculations.business_days_between/2` built a descending range for a reversed
  date pair, which emitted a `Range` deprecation warning at runtime and returned a
  positive count. It now returns a signed result.
- `calculate_age/1` raised `KeyError` on Elixir 1.18 and `BadMapError` on 1.20 for
  non-`Date` input; it now raises `ArgumentError` on every version. Caught by the
  new CI version matrix on its first run.

**Crashes on valid input**

- `calculate_emi/3` raised `ArithmeticError` for a 0% interest rate — both the
  numerator and `power_term - 1` are zero. Interest-free loans now spread the
  principal evenly across the term.
- `to_int/1` raised `FunctionClauseError` on an integer, rejecting the very type it
  returns. It now accepts integers, floats and strings.
- `round_with_precision/2` was guarded on `is_number/1` but called `Float.round/2`,
  which requires a float, so any integer raised `FunctionClauseError`.
- `percentage/3` had no zero-divisor guard and leaked `ArithmeticError`.
- `DateCalculations.add_business_days/2` was guarded on `num_days >= 0`, so
  subtracting business days raised `FunctionClauseError`.

**Shipped artefacts**

- Removed `NumbersToWords.try/0` — a public, zero-arity debug leftover hardcoded to
  `Decimal.new("2.5")` that was shipped in every release since 0.1.0.
- Removed `NumberF.Application`. It was an empty supervisor whose only observable
  effect was making `Supervisor.start_link/2` return `{:error, {:already_started, _}}`.
  The `mod:` key is gone from `mix.exs`; a pure computation library needs no
  supervision tree.
- The dev-only `test.numberf_fast` and `test.numberf_all` mix tasks are excluded from
  the Hex package. They were previously installed into every consuming project.

**Repository**

- **CI had never run.** `ci.yml` and `elixir.yml` were both triggered on
  `push: [main]`; the default branch is `master`. Workflows are rebuilt as `ci.yml`
  (lint / matrix test / package) and `publish.yml`, on `master`.
- The old CI `test` job never invoked `mix test`, and its Credo and Dialyzer steps
  were `continue-on-error` guards around tools that were not dependencies.
- Removed the orphaned `:excoveralls` entry from `mix.lock`, which had been failing
  the `mix deps.unlock --check-unused` gate unnoticed.
- Moved `.github/README.md` to `.github/WORKFLOWS.md`: GitHub renders a README in
  `.github/` in preference to the repository root, so the project's landing page was
  showing CI documentation instead of the library.
- Corrected the `LICENSE` file so GitHub detects it as MIT.
- Repository links pointed at a non-existent `main` branch; they now use `master`.
  This fixes the broken Changelog link on hex.pm.
- Corrected the documented locale count from "25+" to the actual 22, and five
  documented examples whose stated output did not match the library.

### Changed — the facade

`lib/number_f.ex` was 1,879 lines, 72% of it documentation duplicated from the
submodules, with 88 `def` and zero `defdelegate`. Thirty-nine of those functions
reimplemented logic the submodules already contained, which is why
`NumberF.Validation`, `NumberF.Financial` and `NumberF.Formatter` had no callers at
all and had quietly drifted from their facade twins.

- Every public function is now a `defdelegate`; the facade holds the canonical
  documentation and the submodules hold the single implementation. The two can no
  longer disagree.
- Reconciled the drift, with the facade's behaviour taking precedence because it is
  what the documentation promised: `Calculations.round_to_nearest/2` now returns a
  float (was an integer), and `Formatter.to_roman/1` raises `ArgumentError` outside
  1..3999 (was `FunctionClauseError`).
- **All 36 previously unreachable submodule functions are now callable from
  `NumberF`** — every `NumberF.Tax` calculation, `Metrics.convert_units/4` and the
  four unit tables, `Precision.truncate/2`, `precise_format/2`, `custom_round/3` and
  `sanitize_float/2`, `I18n.parse_number/2` and `get_locale_settings/1`,
  `Currencies.convert/5` and `parse/2`, `DateCalculations.add_business_days/2` and
  `next_business_day/1`, and the `Registry` detail lookups. A test now derives the
  expected surface from the submodules, so a new one that is not delegated fails CI.
- `to_int/1`, `to_boolean/1` and `sum_decimal/1` moved to `NumberF.CustomFormatter`,
  alongside the conversions that were already there.
- `NumberF.Statistics` gained the input validation that only the facade copy had.
- The library version is no longer hardcoded in `reference/0`; it is read from
  `mix.exs`.

### Behaviour changes

These change results that were previously wrong. No source change is required.

- `combinations/2` returns an `t:integer/0` rather than a float, computed with the
  multiplicative formula instead of three factorials. `combinations(30, 15)` was
  `155117520.0` and is now `155_117_520`; `combinations(100, 50)` is now exact
  rather than a float approximation.
- Invalid input to `simple_interest/3`, `compound_interest/4`, `calculate_emi/3`,
  `convert_currency/3`, `percentage/3` and `to_int/1` raises `ArgumentError` naming
  the offending argument, instead of leaking `FunctionClauseError` or
  `ArithmeticError`.
- `I18n.spell_number/3` raises for an unsupported language instead of returning
  English.

### Added

- **LLM-readable documentation.** ExDoc 0.40 publishes
  [`llms.txt`](https://hexdocs.pm/number_f/llms.txt) alongside the HTML — an index
  whose every entry has a Markdown twin, so
  [`NumberF.md`](https://hexdocs.pm/number_f/NumberF.md) is the full API as plain
  text — and adds a "Copy Markdown" button to every page. A condensed `llms.txt`
  also ships at the repository root and in the Hex package.
- [Cheatsheet](https://hexdocs.pm/number_f/cheatsheet.html) — every function on one
  page, with output verified against the library rather than transcribed.
- [FAQ guide](https://hexdocs.pm/number_f/faq.html).
- `Statistics.sample_variance/1` and `Statistics.sample_standard_deviation/1`, with
  facade delegates. `variance/1` and `standard_deviation/1` remain the population
  forms; the docs now say which is which.
- `I18n.supported_languages/0` and `NumberF.spelling_languages/0`.
- Credo (strict, with an explicit check allowlist), Dialyzer, and ExCoveralls with a
  ratcheted minimum. `mix lint` runs the same gates CI does.
- `AGENTS.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, GitHub issue forms and a pull
  request template.
- Static SEO and schema.org metadata in the generated docs, plus a canonical URL and
  a favicon.

### Changed

- `decimal` requirement widened to `~> 2.0 or ~> 3.0` so consumers can take the fix
  for [GHSA-rhv4-8758-jx7v](https://github.com/advisories/GHSA-rhv4-8758-jx7v)
  (unbounded exponent DoS, `decimal < 3.0.0`). This library uses only
  `new/to_float/from_float/to_string/round/add`, stable across both majors; the
  suite is verified green against both 2.3.0 and 3.1.1. Resolving 3.x also requires
  `jason >= 1.4.5` in the dev/test closure — 1.4.4 declared
  `decimal ~> 1.0 or ~> 2.0` and held the entire resolution below 3.
- Rewrote `README.md`, which previously duplicated the Getting Started guide.
- Guides ship inside the package tarball.
- `NumberF.NumbersToWords` and `NumberF.NumberToWord` are marked `@moduledoc false`.
  They were never documented and are internal to `to_words/3`; they previously
  appeared in the docs as empty pages. Their functions are unchanged.
- Applied `mix format` across the project; `mix format --check-formatted` had been
  failing.

## [0.1.8] - 2025-05-23

### Changed
- Refactored number formatting and utility functions.

## [0.1.7] - 2025-05-23

### Added
- Comprehensive test suite covering unit, property, integration, concurrency, and
  performance scenarios.

## [0.1.6] - 2025-05-19

### Added
- Custom number formatting with `Decimal` support, removing the `number` dependency.
- Custom delimiter handling for integer inputs.

## [0.1.5] - 2025-05-17


### Added
- **Internationalization Module** (`NumberF.I18n`)
  - Added locale-specific number formatting for 22 locales
  - Added multi-language number spelling (English, French, Spanish, German)
  - Added currency-specific formatting rules

- **Metrics Module** (`NumberF.Metrics`)
  - Added conversion between metric and imperial units
  - Added temperature conversion (Celsius/Fahrenheit)
  - Added customizable unit conversion framework

- **Tax Module** (`NumberF.Tax`)
  - Added VAT calculation with inclusive/exclusive options
  - Added sales tax calculation with configurable rounding
  - Added income tax calculation with progressive brackets
  - Added capital gains tax calculation
  - Added withholding tax calculation
  - Added corporate tax calculation
  - Added payroll tax calculation

- **Precision Module** (`NumberF.Precision`)
  - Added bankers rounding (round to even)
  - Added custom rounding for different thresholds
  - Added approximate equality testing for floating point
  - Added sanitization for special values (NaN, Infinity)

- **Currencies Module** (`NumberF.Currencies`)
  - Added comprehensive currency information database
  - Added currency-specific formatting rules
  - Added multi-currency conversion framework

- **Registry Module** (`NumberF.Registry`)
  - Added module and function discovery utilities
  - Added documentation generator

### Improved
- **Core Module** (`NumberF`)
  - Enhanced organization for better discoverability
  - Added direct access to functionality from submodules
  - Improved documentation with detailed examples
  - Fixed naming conflicts with Kernel functions

- **Documentation**
  - Added comprehensive examples
  - Categorized functions for easier navigation
  - Added cross-references between related functions
  - More detailed parameter descriptions

### Fixed
- Resolved precision issues in floating-point calculations
- Fixed currency symbol placement for different locales
- Addressed multiple default parameter declaration issues

## [0.1.4] - 2025-01-20

### Added
- Initial release with basic functionality
- Currency formatting
- Number to words conversion
- Financial calculations
- Statistical functions
- Memory size formatting
- Random string generation
- Basic type conversion utilities

[0.3.0]: https://github.com/jamesnjovu/elixir_number_functions/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/jamesnjovu/elixir_number_functions/compare/v0.1.8...v0.2.0
[0.1.8]: https://github.com/jamesnjovu/elixir_number_functions/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/jamesnjovu/elixir_number_functions/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/jamesnjovu/elixir_number_functions/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/jamesnjovu/elixir_number_functions/releases/tag/v0.1.5
[0.1.4]: https://github.com/jamesnjovu/elixir_number_functions/releases/tag/v0.1.4
