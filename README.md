# Getting Started with NumberF

NumberF is a powerful utility library for Elixir that makes working with numbers easy and intuitive. This guide will help you get started with the most common features.

## Installation

Add `number_f` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:number_f, "~> 0.1.6"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Basic Usage

Once installed, you can start using NumberF's functionality by importing or accessing it directly:

```elixir
# In your module
defmodule MyApp.SomeModule do
  # You can use NumberF functions directly
  def format_price(price) do
    NumberF.currency(price, "USD")
  end
end
```

## Core Feature Areas

### 1. Number Formatting

```elixir
# Format as currency
NumberF.currency(1234.567)                    # => "ZMW 1,234.57"
NumberF.currency(1234.567, "USD", 2)          # => "USD 1,234.57"

# Format with commas
NumberF.comma_separated(1234567.89)           # => "1,234,567.89"

# Custom delimiters
NumberF.number_to_delimited(1234567.89, delimiter: ".", separator: ",") # => "1.234.567,89"
```

### 2. Number to Text Conversion

```elixir
# Convert numbers to words
NumberF.to_words(20.0)                        # => "Twenty Kwacha and zero Ngwee"
NumberF.to_words(42.75, "Dollars", "Cents")   # => "Forty Two Dollars And Seventy Five Cents"

# Roman numerals
NumberF.to_roman(1999)                        # => "MCMXCIX"
NumberF.from_roman("MCMXCIX")                 # => 1999

# Ordinals
NumberF.ordinal(21)                           # => "21st"
```

### 3. Financial Calculations

```elixir
# Simple interest
NumberF.simple_interest(1000, 0.05, 2)        # => 100.0

# Compound interest
NumberF.compound_interest(1000, 0.05, 2)      # => 102.5
NumberF.compound_interest(1000, 0.05, 2, 12)  # => 104.94 (monthly compounding)

# EMI calculation
NumberF.calculate_emi(100000, 0.10, 12)       # => 8791.59
```

### 4. Statistical Functions

```elixir
# Basic statistics
NumberF.mean([1, 2, 3, 4, 5])                # => 3.0
NumberF.median([1, 3, 5, 7, 9])              # => 5
NumberF.mode([1, 2, 2, 3, 3, 3, 4])          # => [3]
NumberF.standard_deviation([2, 4, 4, 4, 5, 5, 7, 9])  # => 2.0
```

### 5. Internationalization

```elixir
# Format with locale
NumberF.format_number(1234567.89, "en-US")           # => "1,234,567.89"
NumberF.format_number(1234567.89, "fr-FR")           # => "1 234 567,89"

# Currency with locale
NumberF.format_currency(1234.56, "en-US")            # => "$1,234.56"
NumberF.format_currency(1234.56, "fr-FR")            # => "1 234,56 €"
```

## Advanced Features

NumberF includes many advanced features for specialized use cases:

- Tax calculations (VAT, sales tax, income tax)
- Precision handling with multiple rounding strategies
- Unit conversion between metric and imperial
- Date calculations (business days, payment terms)
- Phone number formatting
- Credit card validation
- Memory size humanization

Check the module-specific documentation for details on these advanced features.

## Getting Help

If you need help with NumberF, you can:

1. Read the [full documentation on HexDocs](https://hexdocs.pm/number_f)
2. Open an issue if you encounter a problem or have a feature request

We hope NumberF makes your Elixir development experience more enjoyable!