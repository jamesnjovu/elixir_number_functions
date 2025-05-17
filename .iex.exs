# .iex.exs - for improved IEx console experience with NumberF

# Import NumberF modules for easy access in IEx
import NumberF
import NumberF.Currency
import NumberF.Financial
import NumberF.Statistics

# Create sample data for testing
sample_numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
sample_floats = [1.23, 4.56, 7.89, 10.12, 13.45]
currencies = ["USD", "EUR", "GBP", "JPY", "ZMW"]
locales = ["en-US", "fr-FR", "de-DE", "ja-JP", "en-ZM"]

# Define helper functions for the IEx session
help_number_f = fn ->
  IO.puts """
  \n=== NumberF Interactive Help ===

  Try these examples:

  # Formatting
  NumberF.currency(1234.567)
  NumberF.format_currency(1234.56, "fr-FR")

  # Conversion
  NumberF.to_words(42.75, "Dollars", "Cents")
  NumberF.to_roman(1999)

  # Financial
  NumberF.compound_interest(1000, 0.05, 2, 12)
  NumberF.calculate_emi(100000, 0.10, 12)

  # Statistics
  NumberF.mean(#{inspect(sample_numbers)})
  NumberF.standard_deviation(#{inspect(sample_numbers)})

  # Use sample_numbers, sample_floats, currencies, and locales
  # for experimentation.

  # For more examples, call: examples_number_f()
  # For overview of modules: modules_number_f()
  """
end

examples_number_f = fn ->
  IO.puts """
  \n=== NumberF Examples ===

  === Currency Formatting ===
  #{currencies |> Enum.map(fn c -> "NumberF.currency(1234.56, \"#{c}\")" end) |> Enum.join("\n")}

  === Locale-based Formatting ===
  #{locales |> Enum.map(fn l -> "NumberF.format_number(1234567.89, \"#{l}\")" end) |> Enum.join("\n")}
  #{locales |> Enum.map(fn l -> "NumberF.format_currency(1234.56, \"#{l}\")" end) |> Enum.join("\n")}

  === Number to Words ===
  NumberF.to_words(123.45)
  NumberF.spell_number(42, "en")
  NumberF.spell_number(42, "fr")

  === Statistics ===
  NumberF.mean(#{inspect(sample_numbers)})
  NumberF.median(#{inspect(sample_numbers)})
  NumberF.mode([1, 2, 2, 3, 3, 3, 4])
  """
end

modules_number_f = fn ->
  IO.puts """
  \n=== NumberF Modules ===

  Core:
  - NumberF - Main module with common functions
  - NumberF.Registry - Module and function discovery

  Formatting:
  - NumberF.Currency - Currency formatting
  - NumberF.Formatter - Number formatting utilities
  - NumberF.CustomFormatter - Custom format implementations
  - NumberF.Currencies - Currency information database

  Calculations:
  - NumberF.Calculations - General calculations
  - NumberF.Financial - Financial functions
  - NumberF.Statistics - Statistical functions
  - NumberF.Precision - Precision handling
  - NumberF.Tax - Tax calculations

  Conversion:
  - NumberF.Metrics - Unit conversion
  - NumberF.NumbersToWords - Converting numbers to words

  Utilities:
  - NumberF.Memory - Memory size formatting
  - NumberF.Randomizer - Random string generation
  - NumberF.Validation - Number validation
  - NumberF.DateCalculations - Date-related calculations

  Internationalization:
  - NumberF.I18n - Locale-based formatting
  """
end

# Print welcome message when IEx starts
IO.puts """
\n===== Welcome to NumberF Interactive Console =====

NumberF v#{Application.spec(:number_f, :vsn) || "development"}

Type help_number_f() for interactive help.
"""

# Make the helper functions available in the IEx session
