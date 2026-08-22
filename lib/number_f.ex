defmodule NumberF do
  @moduledoc """
  # NumberF

  A comprehensive utility library for number formatting, calculation, and manipulation in Elixir.

  ## Features

  - **Number Formatting**: Format numbers as currency, with commas, custom delimiters, abbreviated forms (K, M, B)
  - **Text Representation**: Convert numbers to words, ordinals, Roman numerals
  - **Financial Calculations**: Simple/compound interest, EMI calculations, currency conversions, tax calculations
  - **Statistical Functions**: Mean, median, mode, standard deviation, variance
  - **Date Calculations**: Age calculation, business days, payment terms
  - **Validation**: Credit card validation (Luhn algorithm), number format validation
  - **String Generation**: Random string generation, password creation
  - **Type Conversions**: Convert between numeric types and formats
  - **Memory Size**: Convert byte counts to human-readable formats
  - **Phone Formatting**: Format phone numbers based on country codes
  - **Unit Conversion**: Convert between metric and imperial units
  - **Tax Calculations**: VAT, sales tax, income tax calculations
  - **Precision Handling**: Different rounding strategies and precision handling
  - **Internationalization**: Format numbers according to locale conventions

  ## Installation

  Add `number_f` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
  [
    {:number_f, "~> 0.2.0"}
  ]
  end
  ```

  ## Key Functionality

  ### Currency & Number Formatting

  NumberF provides comprehensive formatting capabilities for currency and numbers:

  ```elixir
  # Format as currency with default (ZMW)
  NumberF.currency(1234.567)                    # => "ZMW 1,234.57"

  # Format as US Dollars with 2 decimal places
  NumberF.currency(1234.567, "USD", 2)          # => "USD 1,234.57"

  # Format with French locale (space as thousands separator, comma as decimal)
  NumberF.format_number(1234567.89, "fr-FR")    # => "1 234 567,89"
  ```

  ### Number to Words Conversion

  Convert numeric values to their word representations:

  ```elixir
  # Convert whole number with default currency (Kwacha)
  NumberF.to_words(42)                          # => "Forty Two Kwacha"

  # Convert decimal with custom currency
  NumberF.to_words(42.75, "Dollars", "Cents")   # => "Forty Two Dollars And Seventy Five Cents"

  # Advanced internationalization
  NumberF.spell_number(42, "fr")                # => "Quarante-deux"
  ```

  ### Financial Calculations

  Perform complex financial operations with ease:

  ```elixir
  # Calculate simple interest (principal, rate, time)
  NumberF.simple_interest(1000, 0.05, 2)        # => 100.0

  # Calculate compound interest with monthly compounding
  NumberF.compound_interest(1000, 0.05, 2, 12)  # => 104.94

  # Calculate loan EMI (principal, rate, term in months)
  NumberF.calculate_emi(100000, 0.10, 12)       # => 8791.59

  # Calculate VAT
  NumberF.calculate_vat(100, 0.2)               # => %{net: 100.0, vat: 20.0, gross: 120.0}
  ```

  ### Statistical Functions

  Analyze numerical data with statistical functions:

  ```elixir
  NumberF.mean([1, 2, 3, 4, 5])                 # => 3.0
  NumberF.median([1, 3, 5, 7, 9])               # => 5
  NumberF.mode([1, 2, 2, 3, 3, 3, 4])           # => [3]
  NumberF.standard_deviation([2, 4, 4, 4, 5, 5, 7, 9])  # => 2.0
  ```

  ### Internationalization & Localization

  Format numbers according to locale-specific conventions:

  ```elixir
  # Format with US locale
  NumberF.format_currency(1234.56, "en-US")     # => "$1,234.56"

  # Format with French locale
  NumberF.format_currency(1234.56, "fr-FR")     # => "1 234,56 €"

  # Format with German locale but using USD
  NumberF.format_currency(1234.56, "de-DE", currency_code: "USD")  # => "1.234,56 $"
  ```

  ## Module Organization

  NumberF is organized into specialized modules for different functionality areas:

  - **Core**: `NumberF`, `NumberF.Registry`
  - **Calculation**: `NumberF.Calculations`, `NumberF.Financial`, `NumberF.Statistics`, `NumberF.Precision`, `NumberF.Tax`
  - **Formatting**: `NumberF.Formatter`, `NumberF.CustomFormatter`, `NumberF.Currencies`
  - **Conversion**: `NumberF.Metrics`
  - **Validation**: `NumberF.Validation`
  - **Date**: `NumberF.DateCalculations`
  - **I18n**: `NumberF.I18n`

  Every function documented on those modules is also available directly from
  `NumberF`, which is the recommended entry point. Modules not listed above
  (`NumberF.Currency`, `NumberF.Memory`, `NumberF.Randomizer`, `NumberF.Helper`,
  `NumberF.NumbersToWords`, `NumberF.NumberToWord`) are internal implementation
  details and are not part of the public API.

  For more information, see the [full documentation on HexDocs](https://hexdocs.pm/number_f).
  """

  @doc """
  Formats a number into currency with the specified unit and precision.

  ## Features
  - Automatic digit grouping with thousands separators
  - Configurable decimal precision
  - Support for custom currency symbols/codes
  - Consistent formatting for financial applications

  ## Parameters
    - `number`: The number to format
    - `unit`: The currency unit (default: "ZMW")
    - `precision`: Decimal places (default: 2)

  ## Examples

      iex> NumberF.currency(1234.567)
      "ZMW 1,234.57"

      iex> NumberF.currency(1234.567, "USD", 2)
      "USD 1,234.57"

      iex> NumberF.currency(1234567.89, "€", 0)
      "€ 1,234,568"

      iex> NumberF.currency(nil, "USD", 2)
      nil

  ## Common Use Cases
  - Financial reporting and analysis
  - E-commerce price displays
  - Invoice and receipt generation
  - Banking and financial applications

  ## Related Functions
  - `NumberF.comma_separated/2`: Format numbers with commas but no currency
  - `NumberF.format_currency/3`: Format with locale-specific currency settings
  - `NumberF.number_to_delimited/2`: Format with custom delimiters

  See also: `NumberF.Currencies` for currency-specific information.
  """
  defdelegate currency(number, unit \\ "ZMW", precision \\ 2), to: NumberF.Currency

  @doc """
  Formats a number into comma-separated format with the specified precision.

  ## Parameters
    - `number`: The number to format
    - `precision`: Decimal places (default: 2)

  ## Examples

      iex> NumberF.comma_separated(1234567.89)
      "1,234,567.89"

      iex> NumberF.comma_separated(1234567.89, 0)
      "1,234,568"

      iex> NumberF.comma_separated(nil, 2)
      nil
  """
  defdelegate comma_separated(number, precision \\ 2), to: NumberF.Currency

  @doc """
  Generates a random string of the specified length.

  ## Parameters
    - `length`: The length of the string
    - `type`: Type of string, with options:
      - `:all` (alphanumeric) - default
      - `:alpha` (alphabetical)
      - `:numeric` (numbers)
      - `:upcase` (uppercase)
      - `:downcase` (lowercase)

  ## Examples

      iex> result = NumberF.randomizer(10)
      iex> String.length(result)
      10

      iex> result = NumberF.randomizer(5, :numeric)
      iex> String.length(result) == 5 and String.match?(result, ~r/^[0-9]+$/)
      true

      iex> result = NumberF.randomizer(6, :upcase)
      iex> String.length(result) == 6 and Regex.match?(~r/^[A-Z]+$/, result)
      true
  """
  defdelegate randomizer(length, type \\ :all), to: NumberF.Randomizer

  @doc """
  Generates a default password with pre-defined complexity.
  The pattern is: capitalized 3-letter string + @ + 4 random digits.

  ## Examples

      iex> result = NumberF.default_password()
      iex> String.length(result) == 8 and String.contains?(result, "@")
      true

  """
  defdelegate default_password(), to: NumberF.Randomizer, as: :gen_password

  @doc """
  Converts a number into words with customizable currency terms.

  ## Features
  - Convert integers and decimals to their word representations
  - Support for custom currency terms for main and fractional units
  - Handles numbers from zero to trillions
  - Properly handles decimal values and zero cases

  ## Parameters
    - `amount`: The number to convert
    - `main_currency`: The main currency name (default: "Kwacha")
    - `sec_currency`: The secondary currency name (default: "Ngwee")

  ## Examples

      iex> NumberF.to_words(20.0)
      "Twenty Kwacha"

      iex> NumberF.to_words(42.75, "Dollars", "Cents")
      "Forty Two Dollars And Seventy Five Cents"

      iex> NumberF.to_words(1234567.89, "Euros", "Cents")
      "One Million Two Hundred Thirty Four Thousand Five Hundred Sixty Seven Euros And Eighty Nine Cents"

      iex> NumberF.to_words(0, "Euros", "Cents")
      "zero Euros"

  ## Common Use Cases
  - Check writing and financial documents
  - Legal documents requiring numeric values in words
  - Invoices and receipts
  - Educational applications

  ## Related Functions
  - `NumberF.spell_number/3`: Spell numbers in different languages
  - `NumberF.to_roman/1`: Convert to Roman numerals
  - `NumberF.ordinal/1`: Convert to ordinal forms (1st, 2nd, 3rd)

  See also: `NumberF.NumbersToWords` for more advanced word conversion options.
  """
  defdelegate to_words(amount, main_currency \\ "Kwacha", sec_currency \\ "Ngwee"),
    to: NumberF.NumbersToWords,
    as: :parse

  @doc """
  Converts a memory size in bytes to a human-readable format.
  Automatically selects the appropriate unit (B, KB, MB, GB) based on size.

  ## Parameters
    - `size`: The size in bytes

  ## Examples

      iex> NumberF.memory_size_cal(500)
      "500 B"

      iex> NumberF.memory_size_cal(1024)
      "1.0 KB"

      iex> NumberF.memory_size_cal(1048576)
      "1.0 MB"

      iex> NumberF.memory_size_cal(1073741824)
      "1.0 GB"
  """
  defdelegate memory_size_cal(size), to: NumberF.Memory, as: :humanize

  @doc """
  Converts a string to an integer.

  ## Parameters
    - `value`: The string value to convert

  ## Examples

      iex> NumberF.to_int("123")
      123

      iex> NumberF.to_int("123.45")
      123

  """
  defdelegate to_int(value), to: NumberF.CustomFormatter

  @doc """
  Converts a value to a float.

  ## Parameters
    - `value`: The value to convert (string or number)

  ## Examples

      iex> NumberF.to_float("123.45")
      123.45

      iex> NumberF.to_float(123)
      123.0
  """
  defdelegate to_float(value), to: NumberF.CustomFormatter

  @doc """
  Converts a value to a decimal.

  ## Parameters
    - `value`: The value to convert (string or number)

  ## Examples

      iex> NumberF.to_decimal("123.45")
      Decimal.new("123.45")

      iex> NumberF.to_decimal(123)
      Decimal.new("123")
  """
  defdelegate to_decimal(value), to: NumberF.CustomFormatter

  @doc """
  Converts a string to a boolean value.

  ## Parameters
    - `value`: The string value to convert. Accepts the following:
      - `true`, `yes`, `on` convert to `true`
      - `false`, `no`, `off` convert to `false`
      - Any other value raises an ArgumentError

  ## Examples

      iex> NumberF.to_boolean("true")
      true

      iex> NumberF.to_boolean("yes")
      true

      iex> NumberF.to_boolean("false")
      false

      iex> NumberF.to_boolean("no")
      false
  """
  defdelegate to_boolean(value), to: NumberF.CustomFormatter

  @doc """
  Formats a number into a delimited format with options for customization.

  ## Parameters
    - `number`: The number to format
    - `options`: Keyword options for formatting:
      - `delimiter`: Character used as thousand delimiter (default: ",")
      - `separator`: Character used as decimal separator (default: ".")
      - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.number_to_delimited(1234567.89)
      "1,234,567.89"

      iex> NumberF.number_to_delimited(1234567.89, delimiter: ".", separator: ",")
      "1.234.567,89"

      iex> NumberF.number_to_delimited(1234567.89, precision: 0)
      "1,234,568"
  """
  defdelegate number_to_delimited(number, options \\ []), to: NumberF.CustomFormatter

  @doc """
  Sums a list of decimal numbers.

  ## Parameters
    - `list`: A list of decimal values, potentially nested

  ## Examples

      iex> NumberF.sum_decimal([Decimal.new("1.2"), Decimal.new("3.4"), [Decimal.new("5.6")]])
      Decimal.new("10.2")

      iex> NumberF.sum_decimal([])
      Decimal.new("0")

  This function flattens any nested lists, then uses `Enum.reduce/3` to sum all the decimal values.
  """
  defdelegate sum_decimal(list), to: NumberF.CustomFormatter

  ### NUMERIC CALCULATIONS ###

  @doc """
  Calculates a percentage with specified precision.

  ## Parameters
    - `value`: The value to calculate percentage for
    - `total`: The total value (100%)
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.percentage(25, 100)
      25.0

      iex> NumberF.percentage(1, 3, 2)
      33.33
  """
  defdelegate percentage(value, total, precision \\ 2), to: NumberF.Calculations

  @doc """
  Rounds a number to the nearest specified value.

  ## Parameters
    - `value`: The number to round
    - `nearest`: The nearest value to round to (default: 1.0)

  ## Examples

      iex> NumberF.round_to_nearest(12.3)
      12.0

      iex> NumberF.round_to_nearest(12.3, 5)
      10.0

      iex> NumberF.round_to_nearest(12.3, 0.5)
      12.5
  """
  defdelegate round_to_nearest(value, nearest \\ 1.0), to: NumberF.Calculations

  @doc """
  Checks if a number is within a specified range (inclusive).

  ## Parameters
    - `value`: The number to check
    - `min`: The minimum value of the range
    - `max`: The maximum value of the range

  ## Examples

      iex> NumberF.in_range?(5, 1, 10)
      true

      iex> NumberF.in_range?(15, 1, 10)
      false
  """
  defdelegate in_range?(value, min, max), to: NumberF.Calculations

  ### FINANCIAL FUNCTIONS ###

  @doc """
  Calculates simple interest based on principal, rate and time.

  ## Parameters
    - `principal`: The principal amount
    - `rate`: The annual interest rate as a decimal (e.g., 0.05 for 5%)
    - `time`: The time period in years

  ## Examples

      iex> NumberF.simple_interest(1000, 0.05, 2)
      100.0
  """
  defdelegate simple_interest(principal, rate, time), to: NumberF.Financial

  @doc """
  Calculates compound interest with optional compounding frequency.

  ## Features
  - Support for different compounding frequencies (annual, semi-annual, quarterly, monthly, etc.)
  - Precise calculations using Elixir's floating-point operations
  - Results rounded to 2 decimal places by default
  - Guard clauses ensure valid inputs

  ## Parameters
    - `principal`: The principal amount
    - `rate`: The annual interest rate as a decimal (e.g., 0.05 for 5%)
    - `time`: The time period in years
    - `frequency`: Number of times interest is compounded per year (default: 1)

  ## Examples

      iex> NumberF.compound_interest(1000, 0.05, 2)
      102.5  # Annual compounding (1 time per year)

      iex> NumberF.compound_interest(1000, 0.05, 2, 12)
      104.94  # Monthly compounding (12 times per year)

      iex> NumberF.compound_interest(10000, 0.08, 5, 4)
      4859.47  # Quarterly compounding (4 times per year)

  ## Formula
  The compound interest is calculated using the formula:
  ```
  A = P(1 + r/n)^(nt) - P
  ```
  Where:
  - A = Interest amount
  - P = Principal
  - r = Annual interest rate (decimal)
  - n = Compounding frequency
  - t = Time in years

  ## Common Use Cases
  - Investment calculations
  - Loan and mortgage analysis
  - Retirement planning
  - Financial education tools

  ## Related Functions
  - `NumberF.simple_interest/3`: Calculate simple interest
  - `NumberF.calculate_emi/3`: Calculate equated monthly installments
  - `NumberF.Tax.calculate_capital_gains_tax/3`: Calculate capital gains tax

  See also: `NumberF.Financial` for more financial calculations.
  """
  defdelegate compound_interest(principal, rate, time, frequency \\ 1), to: NumberF.Financial

  @doc """
  Calculates Equated Monthly Installment (EMI) for loans.

  ## Parameters
    - `principal`: The loan amount
    - `rate`: The annual interest rate as a decimal (e.g., 0.05 for 5%)
    - `term_months`: The loan term in months

  ## Examples

      iex> NumberF.calculate_emi(100000, 0.10, 12)
      8791.59
  """
  defdelegate calculate_emi(principal, rate, term_months), to: NumberF.Financial

  @doc """
  Converts an amount between currencies based on exchange rates.

  ## Parameters
    - `amount`: The amount to convert
    - `from_rate`: The exchange rate of the source currency
    - `to_rate`: The exchange rate of the target currency

  ## Examples

      iex> NumberF.convert_currency(100, 1, 1.1)
      110.0
  """
  defdelegate convert_currency(amount, from_rate, to_rate), to: NumberF.Financial

  ### STATISTICAL FUNCTIONS ###

  @doc """
  Calculates the arithmetic mean of a list of numbers.

  ## Features
  - Handles lists of any size
  - Returns nil for empty lists
  - Works with integers and floating-point numbers
  - Accurately calculates average using sum and count

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.mean([1, 2, 3, 4, 5])
      3.0

      iex> NumberF.mean([1.5, 2.5, 3.5])
      2.5

      iex> NumberF.mean([42])
      42.0

      iex> NumberF.mean([])
      nil

  ## Mathematical Definition
  The arithmetic mean is the sum of all values divided by the number of values.

  ## Common Use Cases
  - Data analysis and statistics
  - Financial analysis (average returns, costs, etc.)
  - Scientific calculations
  - Performance metrics

  ## Related Functions
  - `NumberF.median/1`: Calculate the median value
  - `NumberF.mode/1`: Find the most frequent value(s)
  - `NumberF.standard_deviation/1`: Calculate standard deviation
  - `NumberF.variance/1`: Calculate variance

  See also: `NumberF.Statistics` for more statistical functions.
  """
  defdelegate mean(numbers), to: NumberF.Statistics

  @doc """
  Finds the median value from a list of numbers.

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.median([1, 3, 5, 7, 9])
      5

      iex> NumberF.median([1, 3, 5, 7])
      4.0
  """
  defdelegate median(numbers), to: NumberF.Statistics

  @doc """
  Finds the most frequently occurring value(s) in a list.

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.mode([1, 2, 2, 3, 3, 3, 4])
      [3]

      iex> NumberF.mode([1, 1, 2, 2, 3])
      [1, 2]
  """
  defdelegate mode(numbers), to: NumberF.Statistics

  @doc """
  Calculates standard deviation of a dataset.

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.standard_deviation([2, 4, 4, 4, 5, 5, 7, 9])
      2.0
  """
  defdelegate standard_deviation(numbers), to: NumberF.Statistics

  ### NUMBER VALIDATION ###

  @doc """
  Checks if a string is a valid number format.

  ## Parameters
    - `str`: The string to check

  ## Examples

      iex> NumberF.is_valid_number?("123")
      true

      iex> NumberF.is_valid_number?("123.45")
      true

      iex> NumberF.is_valid_number?("abc")
      false
  """
  defdelegate is_valid_number?(str), to: NumberF.Validation

  @doc """
  Checks if a string is a valid integer.

  ## Parameters
    - `str`: The string to check

  ## Examples

      iex> NumberF.is_valid_integer?("123")
      true

      iex> NumberF.is_valid_integer?("123.45")
      false
  """
  defdelegate is_valid_integer?(str), to: NumberF.Validation

  @doc """
  Validates credit card numbers using the Luhn algorithm.

  ## Parameters
    - `number`: The credit card number as a string
    - `type`: Card type to validate against (default: :any)
      - Options: :any, :visa, :mastercard, :amex, :discover

  ## Examples

      iex> NumberF.is_valid_credit_card?("4111111111111111")
      true

      iex> NumberF.is_valid_credit_card?("4111111111111112")
      false
  """
  defdelegate is_valid_credit_card?(number, type \\ :any), to: NumberF.Validation

  ### FORMATTING ENHANCEMENTS ###

  @doc """
  Formats phone numbers based on country code.

  ## Parameters
    - `number`: The phone number as a string
    - `country_code`: The country code (default: "ZM" for Zambia)

  ## Examples

      iex> NumberF.format_phone("260977123456", "ZM")
      "+260 97 712 3456"

      iex> NumberF.format_phone("14155552671", "US")
      "+1 (415) 555-2671"
  """
  defdelegate format_phone(number, country_code \\ "ZM"), to: NumberF.Formatter

  @doc """
  Formats large numbers as K, M, B (e.g., 1.2K, 3.4M).

  ## Parameters
    - `number`: The number to abbreviate
    - `precision`: Number of decimal places (default: 1)

  ## Examples

      iex> NumberF.abbreviate_number(1234)
      "1.2K"

      iex> NumberF.abbreviate_number(1234567)
      "1.2M"

      iex> NumberF.abbreviate_number(1234567890)
      "1.2B"
  """
  defdelegate abbreviate_number(number, precision \\ 1), to: NumberF.Formatter

  @doc """
  Converts numbers to ordinals (1st, 2nd, 3rd, etc.).

  ## Parameters
    - `number`: The number to convert

  ## Examples

      iex> NumberF.ordinal(1)
      "1st"

      iex> NumberF.ordinal(2)
      "2nd"

      iex> NumberF.ordinal(3)
      "3rd"

      iex> NumberF.ordinal(4)
      "4th"
  """
  defdelegate ordinal(number), to: NumberF.Formatter

  @doc """
  Converts Arabic numbers to Roman numerals.

  ## Parameters
    - `number`: The number to convert (1-3999)

  ## Examples

      iex> NumberF.to_roman(4)
      "IV"

      iex> NumberF.to_roman(42)
      "XLII"

      iex> NumberF.to_roman(1999)
      "MCMXCIX"
  """
  defdelegate to_roman(number), to: NumberF.Formatter

  @doc """
  Converts Roman numerals to Arabic numbers.

  ## Parameters
    - `roman`: The Roman numeral string

  ## Examples

      iex> NumberF.from_roman("IV")
      4

      iex> NumberF.from_roman("XLII")
      42

      iex> NumberF.from_roman("MCMXCIX")
      1999
  """
  defdelegate from_roman(roman), to: NumberF.Formatter

  ### DATE-BASED CALCULATIONS ###

  @doc """
  Calculates age based on birth date.

  ## Parameters
    - `birth_date`: Birth date as Date struct

  ## Examples

      iex> birth_date = ~D[1990-01-15]
      iex> age = NumberF.calculate_age(birth_date)
      iex> is_integer(age) and age >= 0
      true
  """
  defdelegate calculate_age(birth_date), to: NumberF.DateCalculations

  @doc """
  Calculates payment due date based on invoice date and terms.

  ## Parameters
    - `invoice_date`: The invoice date as Date struct
    - `terms_days`: Payment terms in days (default: 30)

  ## Examples

      iex> invoice_date = ~D[2023-01-15]
      iex> NumberF.payment_due_date(invoice_date)
      ~D[2023-02-14]

      iex> invoice_date = ~D[2023-01-15]
      iex> NumberF.payment_due_date(invoice_date, 45)
      ~D[2023-03-01]
  """
  defdelegate payment_due_date(invoice_date, terms_days \\ 30), to: NumberF.DateCalculations

  ### UNIT CONVERSION FUNCTIONS ###

  @doc """
  Converts inches to centimeters.

  ## Parameters
    - `inches`: The length in inches

  ## Examples

      iex> NumberF.inches_to_cm(10)
      25.4

      iex> NumberF.inches_to_cm(3.5)
      8.89
  """
  defdelegate inches_to_cm(inches), to: NumberF.Metrics

  @doc """
  Converts centimeters to inches.

  ## Parameters
    - `cm`: The length in centimeters

  ## Examples

      iex> NumberF.cm_to_inches(25.4)
      10.0
  """
  defdelegate cm_to_inches(cm), to: NumberF.Metrics

  @doc """
  Converts miles to kilometers.

  ## Parameters
    - `miles`: The distance in miles

  ## Examples

      iex> NumberF.miles_to_km(10)
      16.09
  """
  defdelegate miles_to_km(miles), to: NumberF.Metrics

  @doc """
  Converts kilometers to miles.

  ## Parameters
    - `km`: The distance in kilometers

  ## Examples

      iex> NumberF.km_to_miles(16.09)
      10.0
  """
  defdelegate km_to_miles(km), to: NumberF.Metrics

  @doc """
  Converts Fahrenheit to Celsius.

  ## Parameters
    - `fahrenheit`: The temperature in Fahrenheit

  ## Examples

      iex> NumberF.fahrenheit_to_celsius(32)
      0.0

      iex> NumberF.fahrenheit_to_celsius(212)
      100.0
  """
  defdelegate fahrenheit_to_celsius(fahrenheit), to: NumberF.Metrics

  @doc """
  Converts Celsius to Fahrenheit.

  ## Parameters
    - `celsius`: The temperature in Celsius

  ## Examples

      iex> NumberF.celsius_to_fahrenheit(0)
      32.0

      iex> NumberF.celsius_to_fahrenheit(100)
      212.0
  """
  defdelegate celsius_to_fahrenheit(celsius), to: NumberF.Metrics

  @doc """
  Converts kilograms to pounds.

  ## Parameters
    - `kg`: The weight in kilograms

  ## Examples

      iex> NumberF.kg_to_pounds(4.54)
      10.01
  """
  defdelegate kg_to_pounds(kg), to: NumberF.Metrics
  ### PRECISION HANDLING FUNCTIONS ###

  @doc """
  Rounds a number to a specified number of decimal places.

  ## Parameters
    - `number`: The number to round
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.round_with_precision(3.14159, 2)
      3.14

      iex> NumberF.round_with_precision(3.14159, 4)
      3.1416
  """
  defdelegate round_with_precision(number, precision \\ 2), to: NumberF.Precision

  @doc """
  Rounds a number using banker's rounding (round to even).
  This is more statistically unbiased than standard rounding.

  ## Parameters
    - `number`: The number to round
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.bankers_round(2.5, 0)
      2.0

      iex> NumberF.bankers_round(3.5, 0)
      4.0
  """
  defdelegate bankers_round(number, precision \\ 2), to: NumberF.Precision

  @doc """
  Rounds a number up to a specified precision (ceiling).

  ## Parameters
    - `number`: The number to round
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.ceiling(3.14159, 2)
      3.15

      iex> NumberF.ceiling(3.14159, 1)
      3.2
  """
  defdelegate ceiling(number, precision \\ 2), to: NumberF.Precision

  @doc """
  Rounds a number down to a specified precision (floor).

  ## Parameters
    - `number`: The number to round
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.floor(3.14159, 2)
      3.14

      iex> NumberF.floor(3.14159, 1)
      3.1
  """
  defdelegate floor(number, precision \\ 2), to: NumberF.Precision

  @doc """
  Rounds a number to a specific increment.

  ## Parameters
    - `number`: The number to round
    - `increment`: The increment to round to (default: 1.0)
    - `strategy`: The rounding strategy (:nearest, :up, :down, or :bankers)

  ## Examples

      iex> NumberF.round_to(3.14159, 0.05, :nearest)
      3.15

      iex> NumberF.round_to(3.14159, 0.1, :up)
      3.2

      iex> NumberF.round_to(3.14159, 0.1, :down)
      3.1
  """
  defdelegate round_to(number, increment \\ 1.0, strategy \\ :nearest), to: NumberF.Precision

  @doc """
  Checks if two floating point numbers are approximately equal.

  ## Parameters
    - `a`: First number
    - `b`: Second number
    - `epsilon`: Maximum allowed difference (default: 1.0e-10)

  ## Examples

      iex> NumberF.approximately_equal(0.1 + 0.2, 0.3)
      true

      iex> NumberF.approximately_equal(0.1, 0.2)
      false
  """
  defdelegate approximately_equal(a, b, epsilon \\ 1.0e-10), to: NumberF.Precision
  ### TAX CALCULATION FUNCTIONS ###

  @doc """
  Calculates Value Added Tax (VAT) for a given amount and rate.

  ## Parameters
    - `amount`: The amount before tax
    - `rate`: The VAT rate as a decimal (e.g., 0.2 for 20%)
    - `included`: Whether the amount already includes VAT (default: false)

  ## Examples

      iex> NumberF.calculate_vat(100, 0.2)
      %{net: 100.0, vat: 20.0, gross: 120.0}

      iex> NumberF.calculate_vat(120, 0.2, true)
      %{net: 100.0, vat: 20.0, gross: 120.0}
  """
  defdelegate calculate_vat(amount, rate, included \\ false), to: NumberF.Tax

  @doc """
  Calculates sales tax for a given amount and rate.

  ## Parameters
    - `amount`: The amount before tax
    - `rate`: The sales tax rate as a decimal (e.g., 0.06 for 6%)
    - `options`: Additional options
      - `:round_to`: Round the tax amount to the nearest value (default: 0.01)

  ## Examples

      iex> NumberF.calculate_sales_tax(100, 0.06)
      %{subtotal: 100.0, tax: 6.0, total: 106.0}
  """
  defdelegate calculate_sales_tax(amount, rate, options \\ []), to: NumberF.Tax

  @doc """
  Returns common VAT rates for different countries.

  ## Examples

      iex> NumberF.vat_rates()["UK"]
      0.2

      iex> NumberF.vat_rates()["Germany"]
      0.19
  """
  defdelegate vat_rates(), to: NumberF.Tax

  ### INTERNATIONALIZATION FUNCTIONS ###

  @doc """
  Formats a number according to locale-specific settings.

  ## Parameters
    - `number`: The number to format
    - `locale`: The locale code (e.g., "en-US", "fr-FR")
    - `options`: Additional formatting options
      - `:precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.format_number(1234567.89, "en-US")
      "1,234,567.89"

      iex> NumberF.format_number(1234567.89, "fr-FR")
      "1 234 567,89"
  """
  defdelegate format_number(number, locale, options \\ []), to: NumberF.I18n

  @doc """
  Formats a number as currency according to locale-specific settings.

  ## Features
  - Supports 100+ international locale formats
  - Proper positioning of currency symbols
  - Correct thousands and decimal separators for each locale
  - Configurable precision and currency code

  ## Parameters
    - `number`: The number to format
    - `locale`: The locale code (e.g., "en-US", "fr-FR")
    - `options`: Additional formatting options
      - `:precision`: Number of decimal places (default: 2)
      - `:currency_code`: ISO currency code to override the locale default
      - `:symbol`: Whether to include the currency symbol (default: true)

  ## Examples

      iex> NumberF.format_currency(1234.56, "en-US")
      "$1,234.56"

      iex> NumberF.format_currency(1234.56, "fr-FR")
      "1 234,56 €"

      iex> NumberF.format_currency(1234.56, "de-DE", currency_code: "USD")
      "1.234,56 $"

      iex> NumberF.format_currency(1234.56, "en-US", symbol: false)
      "1,234.56"

  ## Supported Locales
  This function supports all major world locales including but not limited to:
  en-US, en-GB, fr-FR, de-DE, es-ES, it-IT, ja-JP, zh-CN, ru-RU, pt-BR, and many more.

  ## Common Use Cases
  - Multi-language applications
  - Financial applications with international users
  - E-commerce with global customers
  - Travel and currency conversion applications

  ## Related Functions
  - `NumberF.format_number/3`: Format without currency symbols
  - `NumberF.I18n.get_locale_settings/1`: Get formatting rules for a locale
  - `NumberF.spell_number/3`: Spell out numbers in different languages

  See also: `NumberF.I18n` for more internationalization functions.
  """
  defdelegate format_currency(number, locale, options \\ []), to: NumberF.I18n

  @doc """
  Spells out a number in the specified language.

  ## Parameters
    - `number`: The number to spell out
    - `language`: The language code (e.g., "en", "fr")
    - `options`: Additional options
      - `:capitalize`: Whether to capitalize the first letter (default: true)
      - `:currency`: Whether to add currency names (default: false)
      - `:currency_code`: ISO currency code (default: nil)

  ## Examples

      iex> NumberF.spell_number(42, "en")
      "Forty-two"

      iex> NumberF.spell_number(42, "fr")
      "Quarante-deux"
  """
  defdelegate spell_number(number, language, options \\ []), to: NumberF.I18n
  ### CURRENCY UTILITY FUNCTIONS ###

  @doc """
  Returns a map of currency information with ISO codes, symbols, and formatting details.

  ## Examples

      iex> NumberF.currency_data()["USD"]
      %{
        name: "US Dollar",
        symbol: "$",
        symbol_first: true,
        symbol_space: false,
        decimal_places: 2,
        thousands_separator: ",",
        decimal_separator: "."
      }
  """
  defdelegate currency_data(), to: NumberF.Currencies

  @doc """
  Gets currency details for a specific currency code.

  ## Parameters
    - `currency_code`: ISO currency code (e.g., "USD", "EUR")

  ## Examples

      iex> NumberF.get_currency("USD")
      %{
        name: "US Dollar",
        symbol: "$",
        symbol_first: true,
        symbol_space: false,
        decimal_places: 2,
        thousands_separator: ",",
        decimal_separator: "."
      }
  """
  defdelegate get_currency(currency_code), to: NumberF.Currencies

  @doc """
  Formats a currency with the specified currency code's rules.

  ## Parameters
    - `number`: The number to format
    - `currency_code`: ISO currency code (e.g., "USD", "EUR")
    - `options`: Additional options (override currency defaults)

  ## Examples

      iex> NumberF.format_with_currency(1234.56, "USD")
      "$1,234.56"

      iex> NumberF.format_with_currency(1234.56, "EUR")
      "1.234,56 €"
  """
  defdelegate format_with_currency(number, currency_code, options \\ []),
    to: NumberF.Currencies,
    as: :format

  ### REGISTRY AND INFORMATION ###

  @doc """
  Returns information about all NumberF modules.

  ## Examples

      iex> NumberF.modules() |> Enum.map(& &1.name) |> Enum.take(3)
      ["NumberF", "NumberF.Currency", "NumberF.CustomFormatter"]
  """
  defdelegate modules(), to: NumberF.Registry

  @doc """
  Returns information about NumberF modules of a specific type.

  ## Parameters
    - `type`: The module type (e.g., :formatting, :calculation)

  ## Examples

      iex> NumberF.modules_by_type(:formatting) |> Enum.map(& &1.name)
      ["NumberF.Currency", "NumberF.CustomFormatter", "NumberF.Formatter", "NumberF.Currencies"]
  """
  defdelegate modules_by_type(type), to: NumberF.Registry

  @doc """
  Returns all function categories available in NumberF.

  ## Examples

      iex> NumberF.function_categories() |> Enum.map(& &1.name) |> Enum.take(3)
      ["Formatting", "Conversion", "Generation"]
  """
  defdelegate function_categories(), to: NumberF.Registry

  @doc """
  Returns a markdown documentation of all NumberF modules and functions.

  ## Examples

      iex> markdown = NumberF.documentation()
      iex> String.starts_with?(markdown, "# NumberF Library")
      true
  """
  defdelegate documentation(), to: NumberF.Registry, as: :to_markdown

  ### EXTENDED MATH OPERATIONS ###

  @doc """
  Calculates the factorial of a non-negative integer.

  ## Parameters
    - `n`: The non-negative integer

  ## Examples

      iex> NumberF.factorial(5)
      120

      iex> NumberF.factorial(0)
      1
  """
  defdelegate factorial(n), to: NumberF.Calculations

  @doc """
  Calculates combinations (n choose k).

  ## Parameters
    - `n`: The total number of items
    - `k`: The number of items to choose

  ## Examples

      iex> NumberF.combinations(5, 2)
      10

      iex> NumberF.combinations(10, 3)
      120
  """
  defdelegate combinations(n, k), to: NumberF.Calculations

  @doc """
  Calculates the Greatest Common Divisor (GCD) of two integers.

  ## Parameters
    - `a`: First integer
    - `b`: Second integer

  ## Examples

      iex> NumberF.gcd(48, 18)
      6

      iex> NumberF.gcd(7, 13)
      1
  """
  defdelegate gcd(a, b), to: NumberF.Calculations

  @doc """
  Calculates the Least Common Multiple (LCM) of two integers.

  ## Parameters
    - `a`: First integer
    - `b`: Second integer

  ## Examples

      iex> NumberF.lcm(4, 6)
      12

      iex> NumberF.lcm(21, 6)
      42
  """
  defdelegate lcm(a, b), to: NumberF.Calculations

  @doc """
  Checks if a number is prime.

  ## Parameters
    - `n`: The number to check

  ## Examples

      iex> NumberF.is_prime?(7)
      true

      iex> NumberF.is_prime?(6)
      false
  """
  defdelegate is_prime?(n), to: NumberF.Calculations

  @doc """
  Performs a linear interpolation between two points.

  ## Parameters
    - `x`: The x value to interpolate at
    - `x0`: The x coordinate of the first point
    - `y0`: The y coordinate of the first point
    - `x1`: The x coordinate of the second point
    - `y1`: The y coordinate of the second point

  ## Examples

      iex> NumberF.interpolate(2.5, 2, 10, 3, 20)
      15.0
  """
  defdelegate interpolate(x, x0, y0, x1, y1), to: NumberF.Calculations

  @doc """
  Converts degrees to radians.

  ## Parameters
    - `degrees`: The angle in degrees

  ## Examples

      iex> NumberF.to_radians(180)
      3.141592653589793
  """
  defdelegate to_radians(degrees), to: NumberF.Calculations

  @doc """
  Converts radians to degrees.

  ## Parameters
    - `radians`: The angle in radians

  ## Examples

      iex> NumberF.to_degrees(3.14159)
      179.99984796050427
  """
  defdelegate to_degrees(radians), to: NumberF.Calculations
  ### EXTENDED STATISTICS FUNCTIONS ###

  @doc """
  Calculates the variance of a dataset.

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.variance([2, 4, 4, 4, 5, 5, 7, 9])
      4.0
  """
  defdelegate variance(numbers), to: NumberF.Statistics

  @doc """
  Calculates the **sample** variance of a dataset (divides by N-1).

  Use this when the list is a sample rather than the whole population.
  `NumberF.variance/1` is the population form.

  ## Precision

  The two differ by a factor of `N/(N-1)`, so they converge as the dataset grows
  but diverge sharply for small lists. Most statistical software defaults to the
  sample form; this library keeps `variance/1` as the population form for
  backwards compatibility, so pick one explicitly.

  ## Examples

      iex> NumberF.sample_variance([2, 4, 4, 4, 5, 5, 7, 9])
      4.571428571428571
  """
  defdelegate sample_variance(numbers), to: NumberF.Statistics

  @doc """
  Calculates the **sample** standard deviation of a dataset (divides by N-1).

  See `sample_variance/1`. `NumberF.standard_deviation/1` is the population form.

  ## Examples

      iex> NumberF.sample_standard_deviation([2, 4, 4, 4, 5, 5, 7, 9])
      2.138089935299395
  """
  defdelegate sample_standard_deviation(numbers), to: NumberF.Statistics

  @doc """
  Lists the languages `NumberF.spell_number/3` can spell numbers in.

  Deliberately distinct from the 22 locales `NumberF.format_number/2` supports:
  formatting a locale and spelling its language are different capabilities, and
  conflating them is how an unsupported language used to return English silently.

  ## Examples

      iex> NumberF.spelling_languages()
      ["de", "en", "es", "fr"]
  """
  defdelegate spelling_languages(), to: NumberF.I18n, as: :supported_languages

  @doc """
  Calculates the range (difference between max and min values) of a dataset.

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.range([2, 4, 4, 4, 5, 5, 7, 9])
      7.0
  """
  defdelegate range(numbers), to: NumberF.Statistics
  ### EXTENDED DATE FUNCTIONS ###

  @doc """
  Calculates the number of days between two dates.

  ## Parameters
    - `date1`: The first date
    - `date2`: The second date

  ## Examples

      iex> NumberF.days_between(~D[2023-01-01], ~D[2023-01-10])
      9
  """
  defdelegate days_between(date1, date2), to: NumberF.DateCalculations

  @doc """
  Calculates the number of business days between two dates.

  ## Parameters
    - `date1`: The first date
    - `date2`: The second date

  ## Examples

      iex> NumberF.business_days_between(~D[2023-01-02], ~D[2023-01-08])
      5
  """
  defdelegate business_days_between(date1, date2), to: NumberF.DateCalculations

  @doc """
  Determines if a date is a business day.

  ## Parameters
    - `date`: The date to check

  ## Examples

      iex> NumberF.is_business_day?(~D[2023-01-02])
      true

      iex> NumberF.is_business_day?(~D[2023-01-01])
      false
  """
  defdelegate is_business_day?(date), to: NumberF.DateCalculations

  ### PREVIOUSLY SUBMODULE-ONLY ###
  #
  # These were public on their submodules but unreachable from `NumberF`, so the
  # moduledoc's promise that "most common functionality is available directly from
  # the main NumberF module" was false for 36 functions — including every
  # interesting one in NumberF.Tax. Delegating them makes the facade the complete
  # entry point it claims to be.

  @doc """
  Rounds to a precision using an explicit mode.

  Modes: `:half_up` (default), `:half_down`, `:half_even`, `:ceiling`, `:floor`,
  `:truncate`.

  ## Examples

      iex> NumberF.custom_round(2.565, 2, :half_down)
      2.56
  """
  defdelegate custom_round(number, precision, mode \\ :half_up), to: NumberF.Precision

  @doc """
  Formats a number to a fixed number of decimal places, padding with zeros.

  Unlike `round_to/3`, trailing zeros are preserved, so the width is stable.

  ## Examples

      iex> NumberF.precise_format(3.14159, 3)
      "3.142"
  """
  defdelegate precise_format(number, precision \\ 2), to: NumberF.Precision

  @doc """
  Replaces non-finite float values with a safe default.

  ## Examples

      iex> NumberF.sanitize_float(:nan)
      0.0
  """
  defdelegate sanitize_float(value, default \\ 0.0), to: NumberF.Precision

  @doc """
  Truncates a number to a precision, cutting digits rather than rounding.

  ## Examples

      iex> NumberF.truncate(3.999, 2)
      3.99
  """
  defdelegate truncate(number, precision \\ 2), to: NumberF.Precision

  @doc """
  Calculates progressive income tax against a bracket table.

  ## Examples

      iex> brackets = NumberF.income_tax_brackets()["US"]
      iex> result = NumberF.calculate_income_tax(75_000, brackets)
      iex> is_number(result.tax) and is_number(result.effective_rate)
      true
  """
  defdelegate calculate_income_tax(income, brackets), to: NumberF.Tax

  @doc """
  Reference income tax brackets by country.

  These are reference data, not legal advice: rates change and jurisdictions differ.
  Supply your own brackets for anything with financial consequence.

  ## Examples

      iex> NumberF.income_tax_brackets() |> Map.keys() |> Enum.sort()
      ["Germany", "UK", "US", "Zambia"]
  """
  defdelegate income_tax_brackets(), to: NumberF.Tax

  @doc "Calculates capital gains tax on a gain."
  defdelegate calculate_capital_gains_tax(gain, rate, exemption \\ 0), to: NumberF.Tax

  @doc "Calculates corporate tax on a profit."
  defdelegate calculate_corporate_tax(profit, rate), to: NumberF.Tax

  @doc "Calculates withholding tax on a gross amount."
  defdelegate calculate_withholding_tax(amount, rate), to: NumberF.Tax

  @doc "Calculates employee and employer payroll contributions."
  defdelegate calculate_payroll_tax(salary, employee_rate, employer_rate, cap \\ nil),
    to: NumberF.Tax

  @doc """
  Formats a number in scientific notation.

  ## Examples

      iex> NumberF.scientific_notation(0.000123)
      "1.23e-4"
  """
  defdelegate scientific_notation(number, precision \\ 2), to: NumberF.Formatter

  @doc """
  Formats a number in engineering notation (exponents are multiples of three).

  ## Examples

      iex> NumberF.engineering_notation(0.000123)
      "123.0e-6"
  """
  defdelegate engineering_notation(number, precision \\ 2), to: NumberF.Formatter

  @doc "Formats a value as a percentage string."
  defdelegate format_percentage(value, total, precision \\ 2), to: NumberF.Formatter

  @doc "Formats a numerator and denominator as a fraction."
  defdelegate format_fraction(numerator, denominator, options \\ []), to: NumberF.Formatter

  @doc "Approximates a decimal as a fraction."
  defdelegate decimal_to_fraction(decimal, options \\ []), to: NumberF.Formatter

  @doc "Formats a number with a custom prefix and suffix."
  defdelegate format_with_units(number, options \\ []), to: NumberF.Formatter

  @doc "Formats a number as currency using the low-level formatter."
  defdelegate number_to_currency(number, options \\ []), to: NumberF.CustomFormatter

  @doc "Converts between two currencies using a rate table."
  defdelegate convert_between_currencies(amount, from, to, rates, base_currency \\ "USD"),
    to: NumberF.Currencies,
    as: :convert

  @doc "Parses a currency string into a number."
  defdelegate parse_currency(currency_string, currency_code \\ nil),
    to: NumberF.Currencies,
    as: :parse

  @doc "Converts pounds to kilograms."
  defdelegate pounds_to_kg(pounds), to: NumberF.Metrics

  @doc "Converts millilitres to fluid ounces."
  defdelegate ml_to_oz(ml), to: NumberF.Metrics

  @doc "Converts fluid ounces to millilitres."
  defdelegate oz_to_ml(oz), to: NumberF.Metrics

  @doc "Converts acres to hectares."
  defdelegate acres_to_hectares(acres), to: NumberF.Metrics

  @doc "Converts hectares to acres."
  defdelegate hectares_to_acres(hectares), to: NumberF.Metrics

  @doc """
  Converts between arbitrary units from one of the unit tables.

  Unit keys are strings, not atoms.

  ## Examples

      iex> NumberF.convert_units(100, "km", "mi", NumberF.length_units()) |> Float.round(2)
      62.14
  """
  defdelegate convert_units(value, from, to, units), to: NumberF.Metrics

  @doc "Length conversion factors, relative to metres."
  defdelegate length_units(), to: NumberF.Metrics

  @doc "Weight conversion factors, relative to kilograms."
  defdelegate weight_units(), to: NumberF.Metrics

  @doc "Volume conversion factors, relative to litres."
  defdelegate volume_units(), to: NumberF.Metrics

  @doc "Area conversion factors, relative to square metres."
  defdelegate area_units(), to: NumberF.Metrics

  @doc """
  Adds business days to a date. A negative count subtracts them.

  ## Examples

      iex> NumberF.add_business_days(~D[2024-01-15], -3)
      ~D[2024-01-10]
  """
  defdelegate add_business_days(date, num_days), to: NumberF.DateCalculations

  @doc """
  Returns the next business day after the given date.

  ## Examples

      iex> NumberF.next_business_day(~D[2024-01-12])
      ~D[2024-01-15]
  """
  defdelegate next_business_day(date), to: NumberF.DateCalculations

  @doc """
  Returns the formatting settings for a locale.

  ## Examples

      iex> NumberF.get_locale_settings("en-US").currency_symbol
      "$"
  """
  defdelegate get_locale_settings(locale), to: NumberF.I18n

  @doc """
  Parses a locale-formatted number string back into a number.

  ## Examples

      iex> NumberF.parse_number("1.234,56", "de-DE")
      1234.56
  """
  defdelegate parse_number(text, locale), to: NumberF.I18n

  @doc "Returns the main and sub unit names for a currency in a given language."
  defdelegate get_currency_names(currency_code, language), to: NumberF.I18n

  @doc "Returns metadata for a single NumberF module."
  defdelegate module_details(name), to: NumberF.Registry

  @doc "Returns metadata for a single function category."
  defdelegate category_details(name), to: NumberF.Registry

  ### END PREVIOUSLY SUBMODULE-ONLY ###

  @doc """
  Returns all modules and their functions as a reference.

  This function provides a comprehensive overview of all available functionality
  in the NumberF library, organized by module.

  ## Examples

      iex> ref = NumberF.reference()
      iex> is_map(ref)
      true
  """
  def reference do
    %{
      description:
        "A comprehensive utility library for number formatting, conversion, and manipulation in Elixir",
      version: unquote(Mix.Project.config()[:version]),
      modules: NumberF.Registry.modules(),
      function_categories: NumberF.Registry.function_categories()
    }
  end
end
