# Changelog

All notable changes to the NumberF library will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-05-17

### Added
- **Internationalization Module** (`NumberF.I18n`)
  - Added locale-specific number formatting for 25+ locales
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
