# Changelog

All notable changes to the NumberF library will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-08-22

No breaking changes. This release is focused on documentation, discoverability, and
packaging; the public API is unchanged from 0.1.8.

### Added
- **LLM-readable documentation.** Upgraded to ExDoc 0.40, which publishes
  [`llms.txt`](https://hexdocs.pm/number_f/llms.txt) and
  [`llms-full.txt`](https://hexdocs.pm/number_f/llms-full.txt) alongside the HTML docs,
  and adds a "Copy Markdown" button to every page. A condensed `llms.txt` also ships at
  the root of the repository and in the Hex package.
- **[Cheatsheet](https://hexdocs.pm/number_f/cheatsheet.html)** — every function on one
  page, with output verified against the library rather than transcribed by hand.
- **[FAQ guide](https://hexdocs.pm/number_f/faq.html)** — installation, `Decimal`
  interop, rounding money, how NumberF compares to `ex_cldr` and `ex_money`, and the
  limits of the credit-card and tax functions.
- `AGENTS.md`, `SECURITY.md`, and `CODE_OF_CONDUCT.md`; GitHub issue forms and a pull
  request template.
- Static SEO and schema.org metadata in the generated documentation, plus a canonical
  URL and a favicon.

### Changed
- Rewrote `README.md`, which previously duplicated the Getting Started guide.
- Guides now ship inside the package tarball.
- The `test.numberf_fast` and `test.numberf_all` mix tasks are excluded from the
  published package. They are for developing this library and were previously installed
  into every consuming project.
- `NumberF.NumbersToWords` and `NumberF.NumberToWord` are marked `@moduledoc false`.
  They were never documented and are internal to `NumberF.to_words/3`; they previously
  appeared in the docs as empty, description-less pages. Their functions are unchanged.

### Fixed
- Moved `.github/README.md` to `.github/WORKFLOWS.md`. GitHub renders a README in
  `.github/` in preference to the one at the repository root, so the project's landing
  page was showing CI/CD documentation instead of the library.
- Corrected the `LICENSE` file so GitHub detects it as MIT.
- Repository links pointed at a `main` branch that does not exist; they now point at
  `master`. This fixes the broken Changelog link on hex.pm.
- Aligned the installation version across the README, moduledoc, and every guide.
- Corrected the documented locale count from "25+" to the actual 22.
- Corrected several documented examples whose stated output did not match the library,
  including `bankers_round/1` (defaults to 2 decimal places), `ceiling/2` and `floor/2`
  (which take decimal places, not an increment), and `Metrics.convert_units/4` (whose
  unit keys are strings).
- Applied `mix format` across the project; `mix format --check-formatted` had been
  failing in CI.

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

[0.2.0]: https://github.com/jamesnjovu/elixir_number_functions/compare/v0.1.8...v0.2.0
[0.1.8]: https://github.com/jamesnjovu/elixir_number_functions/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/jamesnjovu/elixir_number_functions/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/jamesnjovu/elixir_number_functions/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/jamesnjovu/elixir_number_functions/releases/tag/v0.1.5
[0.1.4]: https://github.com/jamesnjovu/elixir_number_functions/releases/tag/v0.1.4
