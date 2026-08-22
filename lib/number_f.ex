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
    {:number_f, "~> 0.3.0"}
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
  @doc group: "Currency"
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
  @doc group: "Currency"
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
  @doc group: "Humanize"
  defdelegate randomizer(length, type \\ :all), to: NumberF.Randomizer

  @doc """
  Generates a default password with pre-defined complexity.
  The pattern is: capitalized 3-letter string + @ + 4 random digits.

  ## Examples

      iex> result = NumberF.default_password()
      iex> String.length(result) == 8 and String.contains?(result, "@")
      true

  """
  @doc group: "Humanize"
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
  @doc group: "Text"
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
  @doc group: "Humanize"
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
  @doc group: "Formatting"
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
  @doc group: "Formatting"
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
  @doc group: "Formatting"
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
  @doc group: "Formatting"
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
  @doc group: "Formatting"
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
  @doc group: "Formatting"
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
  @doc group: "Math"
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
  @doc group: "Math"
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
  @doc group: "Math"
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
  @doc group: "Financial"
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
  @doc group: "Financial"
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
  @doc group: "Financial"
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
  @doc group: "Financial"
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
  @doc group: "Statistics"
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
  @doc group: "Statistics"
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
  @doc group: "Statistics"
  defdelegate mode(numbers), to: NumberF.Statistics

  @doc """
  Calculates standard deviation of a dataset.

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.standard_deviation([2, 4, 4, 4, 5, 5, 7, 9])
      2.0
  """
  @doc group: "Statistics"
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
  @doc group: "Validation"
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
  @doc group: "Validation"
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
  @doc group: "Validation"
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
  @doc group: "Formatting"
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
  @doc group: "Formatting"
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
  @doc group: "Formatting"
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
  @doc group: "Formatting"
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
  @doc group: "Formatting"
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
  @doc group: "Dates"
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
  @doc group: "Dates"
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
  @doc group: "Units"
  defdelegate inches_to_cm(inches), to: NumberF.Metrics

  @doc """
  Converts centimeters to inches.

  ## Parameters
    - `cm`: The length in centimeters

  ## Examples

      iex> NumberF.cm_to_inches(25.4)
      10.0
  """
  @doc group: "Units"
  defdelegate cm_to_inches(cm), to: NumberF.Metrics

  @doc """
  Converts miles to kilometers.

  ## Parameters
    - `miles`: The distance in miles

  ## Examples

      iex> NumberF.miles_to_km(10)
      16.09
  """
  @doc group: "Units"
  defdelegate miles_to_km(miles), to: NumberF.Metrics

  @doc """
  Converts kilometers to miles.

  ## Parameters
    - `km`: The distance in kilometers

  ## Examples

      iex> NumberF.km_to_miles(16.09)
      10.0
  """
  @doc group: "Units"
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
  @doc group: "Units"
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
  @doc group: "Units"
  defdelegate celsius_to_fahrenheit(celsius), to: NumberF.Metrics

  @doc """
  Converts kilograms to pounds.

  ## Parameters
    - `kg`: The weight in kilograms

  ## Examples

      iex> NumberF.kg_to_pounds(4.54)
      10.01
  """
  @doc group: "Units"
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
  @doc group: "Precision"
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
  @doc group: "Precision"
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
  @doc group: "Precision"
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
  @doc group: "Precision"
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
  @doc group: "Precision"
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
  @doc group: "Precision"
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
  @doc group: "Tax"
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
  @doc group: "Tax"
  defdelegate calculate_sales_tax(amount, rate, options \\ []), to: NumberF.Tax

  @doc """
  Returns common VAT rates for different countries.

  ## Examples

      iex> NumberF.vat_rates()["UK"]
      0.2

      iex> NumberF.vat_rates()["Germany"]
      0.19
  """
  @doc group: "Tax"
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
  @doc group: "Internationalization"
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
  @doc group: "Internationalization"
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
  @doc group: "Internationalization"
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
  @doc group: "Currency"
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
  @doc group: "Currency"
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
  @doc group: "Currency"
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
  @doc group: "Introspection"
  defdelegate modules(), to: NumberF.Registry

  @doc """
  Returns information about NumberF modules of a specific type.

  ## Parameters
    - `type`: The module type (e.g., :formatting, :calculation)

  ## Examples

      iex> NumberF.modules_by_type(:formatting) |> Enum.map(& &1.name)
      ["NumberF.Currency", "NumberF.CustomFormatter", "NumberF.Formatter", "NumberF.Currencies"]
  """
  @doc group: "Introspection"
  defdelegate modules_by_type(type), to: NumberF.Registry

  @doc """
  Returns all function categories available in NumberF.

  ## Examples

      iex> NumberF.function_categories() |> Enum.map(& &1.name) |> Enum.take(3)
      ["Formatting", "Conversion", "Generation"]
  """
  @doc group: "Introspection"
  defdelegate function_categories(), to: NumberF.Registry

  @doc """
  Returns a markdown documentation of all NumberF modules and functions.

  ## Examples

      iex> markdown = NumberF.documentation()
      iex> String.starts_with?(markdown, "# NumberF Library")
      true
  """
  @doc group: "Introspection"
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
  @doc group: "Math"
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
  @doc group: "Math"
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
  @doc group: "Math"
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
  @doc group: "Math"
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
  @doc group: "Math"
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
  @doc group: "Math"
  defdelegate interpolate(x, x0, y0, x1, y1), to: NumberF.Calculations

  @doc """
  Converts degrees to radians.

  ## Parameters
    - `degrees`: The angle in degrees

  ## Examples

      iex> NumberF.to_radians(180)
      3.141592653589793
  """
  @doc group: "Math"
  defdelegate to_radians(degrees), to: NumberF.Calculations

  @doc """
  Converts radians to degrees.

  ## Parameters
    - `radians`: The angle in radians

  ## Examples

      iex> NumberF.to_degrees(3.14159)
      179.99984796050427
  """
  @doc group: "Math"
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
  @doc group: "Statistics"
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
  @doc group: "Statistics"
  defdelegate sample_variance(numbers), to: NumberF.Statistics

  @doc """
  Calculates the **sample** standard deviation of a dataset (divides by N-1).

  See `sample_variance/1`. `NumberF.standard_deviation/1` is the population form.

  ## Examples

      iex> NumberF.sample_standard_deviation([2, 4, 4, 4, 5, 5, 7, 9])
      2.138089935299395
  """
  @doc group: "Statistics"
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
  @doc group: "Internationalization"
  defdelegate spelling_languages(), to: NumberF.I18n, as: :supported_languages

  @doc """
  Calculates the range (difference between max and min values) of a dataset.

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.range([2, 4, 4, 4, 5, 5, 7, 9])
      7.0
  """
  @doc group: "Statistics"
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
  @doc group: "Dates"
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
  @doc group: "Dates"
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
  @doc group: "Dates"
  defdelegate is_business_day?(date), to: NumberF.DateCalculations

  ### STATISTICS (v0.3.0) ###

  @doc """
  Returns the value at the given percentile (0..100), by linear interpolation.

  ## Examples

      iex> NumberF.percentile([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 25)
      3.25
  """
  @doc group: "Statistics"
  defdelegate percentile(numbers, p), to: NumberF.Statistics

  @doc """
  Returns the first, second and third quartiles.

  ## Examples

      iex> NumberF.quartiles([1, 2, 3, 4, 5, 6, 7, 8])
      %{q1: 2.75, q2: 4.5, q3: 6.25}
  """
  @doc group: "Statistics"
  defdelegate quartiles(numbers), to: NumberF.Statistics

  @doc """
  Interquartile range — the spread of the middle half of the data.

  ## Examples

      iex> NumberF.iqr([1, 2, 3, 4, 5, 6, 7, 8])
      3.5
  """
  @doc group: "Statistics"
  defdelegate iqr(numbers), to: NumberF.Statistics

  @doc """
  How many standard deviations a value sits from the mean.

  ## Examples

      iex> NumberF.z_score(6, 4, 2)
      1.0
  """
  @doc group: "Statistics"
  defdelegate z_score(value, mean, stddev), to: NumberF.Statistics

  @doc """
  Standardises a list to zero mean and unit variance.

  ## Examples

      iex> NumberF.z_scores([2, 4, 6])
      [-1.224744871391589, 0.0, 1.224744871391589]
  """
  @doc group: "Statistics"
  defdelegate z_scores(numbers), to: NumberF.Statistics

  @doc """
  Pearson correlation coefficient between two equal-length lists, in -1..1.

  ## Examples

      iex> NumberF.correlation([1, 2, 3, 4, 5], [2, 4, 5, 4, 5])
      0.7745966692414833
  """
  @doc group: "Statistics"
  defdelegate correlation(xs, ys), to: NumberF.Statistics

  @doc """
  Population covariance of two equal-length lists.

  ## Examples

      iex> NumberF.covariance([1, 2, 3, 4, 5], [2, 4, 5, 4, 5])
      1.2
  """
  @doc group: "Statistics"
  defdelegate covariance(xs, ys), to: NumberF.Statistics

  @doc """
  Least-squares linear regression, returning slope, intercept and r-squared.

  ## Examples

      iex> NumberF.linear_regression([1, 2, 3, 4, 5], [2, 4, 5, 4, 5]).slope
      0.6
  """
  @doc group: "Statistics"
  defdelegate linear_regression(xs, ys), to: NumberF.Statistics

  @doc """
  Mean weighted by a matching list of weights.

  ## Examples

      iex> NumberF.weighted_mean([90, 80, 70], [0.5, 0.3, 0.2])
      83.0
  """
  @doc group: "Statistics"
  defdelegate weighted_mean(values, weights), to: NumberF.Statistics

  @doc """
  Geometric mean — the correct average for growth rates and ratios.

  ## Examples

      iex> NumberF.geometric_mean([1, 4, 16]) |> Float.round(4)
      4.0
  """
  @doc group: "Statistics"
  defdelegate geometric_mean(numbers), to: NumberF.Statistics

  @doc """
  Harmonic mean — the correct average for rates over a fixed distance.

  ## Examples

      iex> NumberF.harmonic_mean([40, 60]) |> Float.round(6)
      48.0
  """
  @doc group: "Statistics"
  defdelegate harmonic_mean(numbers), to: NumberF.Statistics

  @doc """
  A one-call description of a dataset: count, min, quartiles, max, mean, stddev.

  ## Examples

      iex> NumberF.summary([1, 2, 3, 4, 5]).median
      3
  """
  @doc group: "Statistics"
  defdelegate summary(numbers), to: NumberF.Statistics

  @doc """
  Simple moving average over a sliding window.

  ## Examples

      iex> NumberF.moving_average([1, 2, 3, 4, 5], 3)
      [2.0, 3.0, 4.0]
  """
  @doc group: "Statistics"
  defdelegate moving_average(numbers, window), to: NumberF.Statistics

  @doc """
  Running total of a list.

  ## Examples

      iex> NumberF.cumulative_sum([1, 2, 3, 4])
      [1, 3, 6, 10]
  """
  @doc group: "Statistics"
  defdelegate cumulative_sum(numbers), to: NumberF.Statistics

  @doc """
  Rescales a list to the 0..1 range.

  ## Examples

      iex> NumberF.normalize([10, 20, 30])
      [0.0, 0.5, 1.0]
  """
  @doc group: "Statistics"
  defdelegate normalize(numbers), to: NumberF.Statistics

  @doc """
  Values falling outside the expected spread. `method: :iqr` (default) or `:zscore`.

  ## Examples

      iex> NumberF.outliers([1, 2, 3, 4, 1000])
      [1000]
  """
  @doc group: "Statistics"
  defdelegate outliers(numbers, options \\ []), to: NumberF.Statistics

  @doc """
  The list with its outliers removed.

  ## Examples

      iex> NumberF.remove_outliers([1, 2, 3, 4, 1000])
      [1, 2, 3, 4]
  """
  @doc group: "Statistics"
  defdelegate remove_outliers(numbers, options \\ []), to: NumberF.Statistics

  @doc """
  Counts how often each value occurs.

  ## Examples

      iex> NumberF.frequency_distribution([1, 2, 2, 3, 3, 3])
      %{1 => 1, 2 => 2, 3 => 3}
  """
  @doc group: "Statistics"
  defdelegate frequency_distribution(numbers), to: NumberF.Statistics

  @doc """
  Mean after discarding a proportion from each end — robust to unreliable extremes.

  ## Examples

      iex> NumberF.trimmed_mean([1, 2, 3, 4, 100], 0.2)
      3.0
  """
  @doc group: "Statistics"
  defdelegate trimmed_mean(numbers, proportion \\ 0.1), to: NumberF.Statistics

  @doc """
  Standard deviation as a proportion of the mean — a unitless measure of spread.

  ## Examples

      iex> NumberF.coefficient_of_variation([2, 4, 4, 4, 5, 5, 7, 9])
      0.4
  """
  @doc group: "Statistics"
  defdelegate coefficient_of_variation(numbers), to: NumberF.Statistics

  ### PRECISION AND FINANCIAL (v0.3.0) ###

  @doc """
  Constrains a value to a range.

  ## Examples

      iex> NumberF.clamp(15, 0, 10)
      10

      iex> NumberF.clamp(-5, 0, 10)
      0
  """
  @doc group: "Precision"
  defdelegate clamp(value, min, max), to: NumberF.Precision

  @doc """
  Divides, returning `default` instead of raising when the denominator is zero.

  ## Examples

      iex> NumberF.safe_divide(10, 0)
      0.0

      iex> NumberF.safe_divide(10, 4)
      2.5
  """
  @doc group: "Precision"
  defdelegate safe_divide(numerator, denominator, default \\ 0.0), to: NumberF.Precision

  @doc """
  Returns -1, 0 or 1 according to the sign of the number.

  ## Examples

      iex> NumberF.sign(-4.2)
      -1
  """
  @doc group: "Precision"
  defdelegate sign(number), to: NumberF.Precision

  @doc """
  Rounds half away from zero — "round half up" as most people mean it.

  Contrast `bankers_round/2`, which rounds half to even to avoid upward bias.

  ## Examples

      iex> NumberF.round_half_away_from_zero(-2.5, 0)
      -3.0
  """
  @doc group: "Precision"
  defdelegate round_half_away_from_zero(number, precision \\ 2), to: NumberF.Precision

  @doc """
  Rounds half to even. A discoverable alias for `bankers_round/2`.

  ## Examples

      iex> NumberF.round_half_even(2.5, 0)
      2.0
  """
  @doc group: "Precision"
  defdelegate round_half_even(number, precision \\ 2), to: NumberF.Precision

  @doc """
  Present value of a future sum.

  ## Examples

      iex> NumberF.present_value(1000, 0.05, 10)
      613.91
  """
  @doc group: "Financial"
  defdelegate present_value(future_value, rate, periods), to: NumberF.Financial

  @doc """
  Future value of a present sum.

  ## Examples

      iex> NumberF.future_value(1000, 0.05, 10)
      1628.89
  """
  @doc group: "Financial"
  defdelegate future_value(present_value, rate, periods), to: NumberF.Financial

  @doc """
  Net present value of a series of cash flows, the first at t=0.

  ## Examples

      iex> NumberF.npv(0.1, [-1000, 300, 400, 500, 600])
      388.77
  """
  @doc group: "Financial"
  defdelegate npv(rate, cash_flows), to: NumberF.Financial

  @doc """
  Internal rate of return. Returns `{:ok, rate}` or an error tuple.

  ## Examples

      iex> {:ok, rate} = NumberF.irr([-1000, 300, 400, 500, 600])
      iex> Float.round(rate, 4)
      0.2489
  """
  @doc group: "Financial"
  defdelegate irr(cash_flows, options \\ []), to: NumberF.Financial

  @doc """
  Full amortization schedule for a loan, one entry per period.

  ## Examples

      iex> NumberF.amortization_schedule(100_000, 0.10, 12) |> List.last() |> Map.get(:balance)
      0.0
  """
  @doc group: "Financial"
  defdelegate amortization_schedule(principal, annual_rate, term_months), to: NumberF.Financial

  @doc """
  Return on investment, as a percentage.

  ## Examples

      iex> NumberF.roi(1500, 1000)
      50.0
  """
  @doc group: "Financial"
  defdelegate roi(gain, cost), to: NumberF.Financial

  @doc """
  Compound annual growth rate, as a percentage.

  ## Examples

      iex> NumberF.cagr(1000, 2000, 5)
      14.87
  """
  @doc group: "Financial"
  defdelegate cagr(beginning_value, ending_value, years), to: NumberF.Financial

  @doc """
  Effective annual rate for a nominal rate compounded n times per year.

  ## Examples

      iex> NumberF.effective_annual_rate(0.12, 12)
      0.1268
  """
  @doc group: "Financial"
  defdelegate effective_annual_rate(nominal_rate, compounds_per_year), to: NumberF.Financial

  @doc """
  Level loan payment. Unlike `calculate_emi/3`'s history, safe at a zero rate.

  ## Examples

      iex> NumberF.loan_payment(100_000, 0.0, 12)
      8333.33
  """
  @doc group: "Financial"
  defdelegate loan_payment(principal, annual_rate, term_months), to: NumberF.Financial

  @doc """
  Payment required to amortise a present value over n periods.

  ## Examples

      iex> NumberF.annuity_payment(10_000, 0.05, 10)
      1295.05
  """
  @doc group: "Financial"
  defdelegate annuity_payment(present_value, rate, periods), to: NumberF.Financial

  @doc """
  Present value of a stream of equal payments.

  ## Examples

      iex> NumberF.annuity_present_value(100, 0.05, 10)
      772.17
  """
  @doc group: "Financial"
  defdelegate annuity_present_value(payment, rate, periods), to: NumberF.Financial

  @doc """
  Future value of a stream of equal payments.

  ## Examples

      iex> NumberF.annuity_future_value(100, 0.05, 10)
      1257.79
  """
  @doc group: "Financial"
  defdelegate annuity_future_value(payment, rate, periods), to: NumberF.Financial

  @doc """
  Straight-line depreciation per year.

  ## Examples

      iex> NumberF.depreciation_straight_line(10_000, 1_000, 5)
      1800.0
  """
  @doc group: "Financial"
  defdelegate depreciation_straight_line(cost, salvage, life_years), to: NumberF.Financial

  @doc """
  Declining-balance depreciation schedule. `factor` defaults to 2.

  ## Examples

      iex> NumberF.depreciation_declining_balance(10_000, 1_000, 5) |> hd()
      %{year: 1, depreciation: 4000.0, book_value: 6000.0}
  """
  @doc group: "Financial"
  defdelegate depreciation_declining_balance(cost, salvage, life_years, factor \\ 2),
    to: NumberF.Financial

  @doc """
  Units that must be sold to cover fixed costs.

  ## Examples

      iex> NumberF.break_even_point(10_000, 25, 15)
      1000.0
  """
  @doc group: "Financial"
  defdelegate break_even_point(fixed_costs, price_per_unit, variable_cost_per_unit),
    to: NumberF.Financial

  @doc """
  Years until cumulative cash flows repay an initial investment.

  ## Examples

      iex> NumberF.payback_period(1000, [300, 400, 500])
      {:ok, 2.6}
  """
  @doc group: "Financial"
  defdelegate payback_period(initial_investment, cash_flows), to: NumberF.Financial

  ### MATH, FORMATTING, VALIDATION AND DATES (v0.3.0) ###

  @doc """
  Ordered arrangements of k items from n (nPk).

  ## Examples

      iex> NumberF.permutations(5, 2)
      20
  """
  @doc group: "Math"
  defdelegate permutations(n, k), to: NumberF.Calculations

  @doc """
  The nth Fibonacci number, exact for any n.

  ## Examples

      iex> NumberF.fibonacci(10)
      55
  """
  @doc group: "Math"
  defdelegate fibonacci(n), to: NumberF.Calculations

  @doc """
  The first n Fibonacci numbers.

  ## Examples

      iex> NumberF.fibonacci_sequence(8)
      [0, 1, 1, 2, 3, 5, 8, 13]
  """
  @doc group: "Math"
  defdelegate fibonacci_sequence(n), to: NumberF.Calculations

  @doc """
  Prime factorisation, ascending and with repeats.

  ## Examples

      iex> NumberF.prime_factors(360)
      [2, 2, 2, 3, 3, 5]
  """
  @doc group: "Math"
  defdelegate prime_factors(n), to: NumberF.Calculations

  @doc """
  All positive divisors of n, ascending.

  ## Examples

      iex> NumberF.divisors(28)
      [1, 2, 4, 7, 14, 28]
  """
  @doc group: "Math"
  defdelegate divisors(n), to: NumberF.Calculations

  @doc """
  The decimal digits of an integer.

  ## Examples

      iex> NumberF.digits(12345)
      [1, 2, 3, 4, 5]
  """
  @doc group: "Math"
  defdelegate digits(n), to: NumberF.Calculations

  @doc """
  Sum of the decimal digits.

  ## Examples

      iex> NumberF.digit_sum(12345)
      15
  """
  @doc group: "Math"
  defdelegate digit_sum(n), to: NumberF.Calculations

  @doc """
  Repeatedly sums the digits until one remains.

  ## Examples

      iex> NumberF.digital_root(12345)
      6
  """
  @doc group: "Math"
  defdelegate digital_root(n), to: NumberF.Calculations

  @doc """
  The integer with its digits reversed.

  ## Examples

      iex> NumberF.reverse_number(12345)
      54321
  """
  @doc group: "Math"
  defdelegate reverse_number(n), to: NumberF.Calculations

  @doc """
  Whether the digits read the same both ways.

  ## Examples

      iex> NumberF.palindrome?(12321)
      true
  """
  @doc group: "Math"
  defdelegate palindrome?(n), to: NumberF.Calculations

  @doc """
  Whether n is a perfect square, without float error.

  ## Examples

      iex> NumberF.perfect_square?(144)
      true
  """
  @doc group: "Math"
  defdelegate perfect_square?(n), to: NumberF.Calculations

  @doc """
  The real nth root of a number.

  ## Examples

      iex> NumberF.nth_root(27, 3)
      3.0
  """
  @doc group: "Math"
  defdelegate nth_root(number, n), to: NumberF.Calculations

  @doc """
  Logarithm in an arbitrary base.

  ## Examples

      iex> NumberF.log_base(1024, 2)
      10.0
  """
  @doc group: "Math"
  defdelegate log_base(number, base), to: NumberF.Calculations

  @doc """
  Renders an integer in a base from 2 to 36.

  ## Examples

      iex> NumberF.to_base(255, 16)
      "FF"
  """
  @doc group: "Math"
  defdelegate to_base(number, base), to: NumberF.Calculations

  @doc """
  Parses an integer written in a base from 2 to 36.

  ## Examples

      iex> NumberF.from_base("FF", 16)
      255
  """
  @doc group: "Math"
  defdelegate from_base(string, base), to: NumberF.Calculations

  @doc """
  Renders an integer in hexadecimal.

  ## Examples

      iex> NumberF.to_hex(255)
      "FF"
  """
  @doc group: "Math"
  defdelegate to_hex(number), to: NumberF.Calculations

  @doc """
  Parses a hexadecimal integer.

  ## Examples

      iex> NumberF.from_hex("FF")
      255
  """
  @doc group: "Math"
  defdelegate from_hex(string), to: NumberF.Calculations

  @doc """
  Renders an integer in binary.

  ## Examples

      iex> NumberF.to_binary(5)
      "101"
  """
  @doc group: "Math"
  defdelegate to_binary(number), to: NumberF.Calculations

  @doc """
  Parses a binary integer.

  ## Examples

      iex> NumberF.from_binary("101")
      5
  """
  @doc group: "Math"
  defdelegate from_binary(string), to: NumberF.Calculations

  @doc """
  Renders an integer in octal.

  ## Examples

      iex> NumberF.to_octal(8)
      "10"
  """
  @doc group: "Math"
  defdelegate to_octal(number), to: NumberF.Calculations

  @doc """
  Parses an octal integer.

  ## Examples

      iex> NumberF.from_octal("10")
      8
  """
  @doc group: "Math"
  defdelegate from_octal(string), to: NumberF.Calculations

  @doc """
  Accounting format: negatives in parentheses.

  ## Examples

      iex> NumberF.accounting_format(-1234.56, unit: "$")
      "($1,234.56)"
  """
  @doc group: "Formatting"
  defdelegate accounting_format(number, options \\ []), to: NumberF.Formatter

  @doc """
  Human-readable byte size. `base: :binary` for KiB/MiB.

  ## Examples

      iex> NumberF.format_bytes(1_500_000)
      "1.5 MB"
  """
  @doc group: "Formatting"
  defdelegate format_bytes(bytes, options \\ []), to: NumberF.Formatter

  @doc """
  Human-readable duration. `format:` `:short`, `:long` or `:clock`.

  ## Examples

      iex> NumberF.format_duration(3725)
      "1h 2m 5s"
  """
  @doc group: "Formatting"
  defdelegate format_duration(seconds, options \\ []), to: NumberF.Formatter

  @doc """
  Rounds to a number of significant figures.

  ## Examples

      iex> NumberF.significant_figures(1234.5678, 3)
      1230.0
  """
  @doc group: "Formatting"
  defdelegate significant_figures(number, digits), to: NumberF.Formatter

  @doc """
  Formats to significant figures, keeping trailing zeros.

  ## Examples

      iex> NumberF.format_significant(1.5, 4)
      "1.500"
  """
  @doc group: "Formatting"
  defdelegate format_significant(number, digits), to: NumberF.Formatter

  @doc """
  Prefixes a number with an explicit sign.

  ## Examples

      iex> NumberF.with_sign(42)
      "+42"
  """
  @doc group: "Formatting"
  defdelegate with_sign(number, options \\ []), to: NumberF.Formatter

  @doc """
  Pads a number to a fixed width.

  ## Examples

      iex> NumberF.pad_number(42, 6, char: "0")
      "000042"
  """
  @doc group: "Formatting"
  defdelegate pad_number(number, width, options \\ []), to: NumberF.Formatter

  @doc """
  Pairs a count with a correctly pluralised noun.

  ## Examples

      iex> NumberF.pluralize(3, "person", "people")
      "3 people"
  """
  @doc group: "Formatting"
  defdelegate pluralize(count, singular, plural \\ nil), to: NumberF.Formatter

  @doc """
  Validates an IBAN by its mod-97 checksum.

  ## Examples

      iex> NumberF.valid_iban?("GB82 WEST 1234 5698 7654 32")
      true
  """
  @doc group: "Validation"
  defdelegate valid_iban?(iban), to: NumberF.Validation

  @doc """
  Validates an ISBN-10 or ISBN-13.

  ## Examples

      iex> NumberF.valid_isbn?("978-3-16-148410-0")
      true
  """
  @doc group: "Validation"
  defdelegate valid_isbn?(isbn), to: NumberF.Validation

  @doc """
  Validates an EAN-8 or EAN-13 barcode.

  ## Examples

      iex> NumberF.valid_ean?("4006381333931")
      true
  """
  @doc group: "Validation"
  defdelegate valid_ean?(code), to: NumberF.Validation

  @doc """
  Validates a UPC-A barcode.

  ## Examples

      iex> NumberF.valid_upc?("036000291452")
      true
  """
  @doc group: "Validation"
  defdelegate valid_upc?(code), to: NumberF.Validation

  @doc """
  Identifies a card network from its number.

  ## Examples

      iex> NumberF.card_brand("4111111111111111")
      :visa
  """
  @doc group: "Validation"
  defdelegate card_brand(number), to: NumberF.Validation

  @doc """
  Computes the Luhn check digit for a number.

  ## Examples

      iex> NumberF.luhn_check_digit("411111111111111")
      1
  """
  @doc group: "Validation"
  defdelegate luhn_check_digit(partial), to: NumberF.Validation

  @doc """
  Validates any Luhn-checksummed number.

  ## Examples

      iex> NumberF.valid_luhn?("4111111111111111")
      true
  """
  @doc group: "Validation"
  defdelegate valid_luhn?(number), to: NumberF.Validation

  @doc """
  Validates a US ABA routing number.

  ## Examples

      iex> NumberF.valid_routing_number?("021000021")
      true
  """
  @doc group: "Validation"
  defdelegate valid_routing_number?(number), to: NumberF.Validation

  @doc """
  Validates a 15-digit IMEI.

  ## Examples

      iex> NumberF.valid_imei?("490154203237518")
      true
  """
  @doc group: "Validation"
  defdelegate valid_imei?(imei), to: NumberF.Validation

  @doc """
  Whether the code is a currency this library knows.

  ## Examples

      iex> NumberF.valid_currency_code?("USD")
      true
  """
  @doc group: "Validation"
  defdelegate valid_currency_code?(code), to: NumberF.Validation

  @doc """
  Whether a value is a number in 0..100.

  ## Examples

      iex> NumberF.valid_percentage?(42.5)
      true
  """
  @doc group: "Validation"
  defdelegate valid_percentage?(value), to: NumberF.Validation

  @doc """
  Calendar quarter of a date, 1 to 4.

  ## Examples

      iex> NumberF.quarter(~D[2024-08-22])
      3
  """
  @doc group: "Dates"
  defdelegate quarter(date), to: NumberF.DateCalculations

  @doc """
  First day of the date's quarter.

  ## Examples

      iex> NumberF.quarter_start(~D[2024-08-22])
      ~D[2024-07-01]
  """
  @doc group: "Dates"
  defdelegate quarter_start(date), to: NumberF.DateCalculations

  @doc """
  Last day of the date's quarter.

  ## Examples

      iex> NumberF.quarter_end(~D[2024-08-22])
      ~D[2024-09-30]
  """
  @doc group: "Dates"
  defdelegate quarter_end(date), to: NumberF.DateCalculations

  @doc """
  Fiscal year containing the date, named for the year it ends in.

  ## Examples

      iex> NumberF.fiscal_year(~D[2024-08-22], 4)
      2025
  """
  @doc group: "Dates"
  defdelegate fiscal_year(date, start_month \\ 4), to: NumberF.DateCalculations

  @doc """
  Number of days in a month.

  ## Examples

      iex> NumberF.days_in_month(2024, 2)
      29
  """
  @doc group: "Dates"
  defdelegate days_in_month(year, month), to: NumberF.DateCalculations

  @doc """
  Whether a year is a leap year.

  ## Examples

      iex> NumberF.leap_year?(2024)
      true
  """
  @doc group: "Dates"
  defdelegate leap_year?(year), to: NumberF.DateCalculations

  @doc """
  ISO-8601 week number.

  ## Examples

      iex> NumberF.week_number(~D[2024-08-22])
      34
  """
  @doc group: "Dates"
  defdelegate week_number(date), to: NumberF.DateCalculations

  @doc """
  First day of the date's month.

  ## Examples

      iex> NumberF.month_start(~D[2024-08-22])
      ~D[2024-08-01]
  """
  @doc group: "Dates"
  defdelegate month_start(date), to: NumberF.DateCalculations

  @doc """
  Last day of the date's month.

  ## Examples

      iex> NumberF.month_end(~D[2024-02-10])
      ~D[2024-02-29]
  """
  @doc group: "Dates"
  defdelegate month_end(date), to: NumberF.DateCalculations

  @doc """
  Age in whole months.

  ## Examples

      iex> NumberF.age_in_months(~D[2020-01-15], ~D[2024-08-22])
      55
  """
  @doc group: "Dates"
  defdelegate age_in_months(birth_date, as_of \\ Date.utc_today()), to: NumberF.DateCalculations

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
  @doc group: "Precision"
  defdelegate custom_round(number, precision, mode \\ :half_up), to: NumberF.Precision

  @doc """
  Formats a number to a fixed number of decimal places, padding with zeros.

  Unlike `round_to/3`, trailing zeros are preserved, so the width is stable.

  ## Examples

      iex> NumberF.precise_format(3.14159, 3)
      "3.142"
  """
  @doc group: "Precision"
  defdelegate precise_format(number, precision \\ 2), to: NumberF.Precision

  @doc """
  Replaces non-finite float values with a safe default.

  ## Examples

      iex> NumberF.sanitize_float(:nan)
      0.0
  """
  @doc group: "Precision"
  defdelegate sanitize_float(value, default \\ 0.0), to: NumberF.Precision

  @doc """
  Truncates a number to a precision, cutting digits rather than rounding.

  ## Examples

      iex> NumberF.truncate(3.999, 2)
      3.99
  """
  @doc group: "Precision"
  defdelegate truncate(number, precision \\ 2), to: NumberF.Precision

  @doc """
  Calculates progressive income tax against a bracket table.

  ## Examples

      iex> brackets = NumberF.income_tax_brackets()["US"]
      iex> result = NumberF.calculate_income_tax(75_000, brackets)
      iex> is_number(result.tax) and is_number(result.effective_rate)
      true
  """
  @doc group: "Tax"
  defdelegate calculate_income_tax(income, brackets), to: NumberF.Tax

  @doc """
  Reference income tax brackets by country.

  These are reference data, not legal advice: rates change and jurisdictions differ.
  Supply your own brackets for anything with financial consequence.

  ## Examples

      iex> NumberF.income_tax_brackets() |> Map.keys() |> Enum.sort()
      ["Germany", "UK", "US", "Zambia"]
  """
  @doc group: "Tax"
  defdelegate income_tax_brackets(), to: NumberF.Tax

  @doc "Calculates capital gains tax on a gain."
  @doc group: "Tax"
  defdelegate calculate_capital_gains_tax(gain, rate, exemption \\ 0), to: NumberF.Tax

  @doc "Calculates corporate tax on a profit."
  @doc group: "Tax"
  defdelegate calculate_corporate_tax(profit, rate), to: NumberF.Tax

  @doc "Calculates withholding tax on a gross amount."
  @doc group: "Tax"
  defdelegate calculate_withholding_tax(amount, rate), to: NumberF.Tax

  @doc "Calculates employee and employer payroll contributions."
  @doc group: "Tax"
  defdelegate calculate_payroll_tax(salary, employee_rate, employer_rate, cap \\ nil),
    to: NumberF.Tax

  @doc """
  Formats a number in scientific notation.

  ## Examples

      iex> NumberF.scientific_notation(0.000123)
      "1.23e-4"
  """
  @doc group: "Formatting"
  defdelegate scientific_notation(number, precision \\ 2), to: NumberF.Formatter

  @doc """
  Formats a number in engineering notation (exponents are multiples of three).

  ## Examples

      iex> NumberF.engineering_notation(0.000123)
      "123.0e-6"
  """
  @doc group: "Formatting"
  defdelegate engineering_notation(number, precision \\ 2), to: NumberF.Formatter

  @doc "Formats a value as a percentage string."
  @doc group: "Formatting"
  defdelegate format_percentage(value, total, precision \\ 2), to: NumberF.Formatter

  @doc "Formats a numerator and denominator as a fraction."
  @doc group: "Formatting"
  defdelegate format_fraction(numerator, denominator, options \\ []), to: NumberF.Formatter

  @doc "Approximates a decimal as a fraction."
  @doc group: "Formatting"
  defdelegate decimal_to_fraction(decimal, options \\ []), to: NumberF.Formatter

  @doc "Formats a number with a custom prefix and suffix."
  @doc group: "Formatting"
  defdelegate format_with_units(number, options \\ []), to: NumberF.Formatter

  @doc "Formats a number as currency using the low-level formatter."
  @doc group: "Formatting"
  defdelegate number_to_currency(number, options \\ []), to: NumberF.CustomFormatter

  @doc "Converts between two currencies using a rate table."
  @doc group: "Currency"
  defdelegate convert_between_currencies(amount, from, to, rates, base_currency \\ "USD"),
    to: NumberF.Currencies,
    as: :convert

  @doc "Parses a currency string into a number."
  @doc group: "Currency"
  defdelegate parse_currency(currency_string, currency_code \\ nil),
    to: NumberF.Currencies,
    as: :parse

  @doc "Converts pounds to kilograms."
  @doc group: "Units"
  defdelegate pounds_to_kg(pounds), to: NumberF.Metrics

  @doc "Converts millilitres to fluid ounces."
  @doc group: "Units"
  defdelegate ml_to_oz(ml), to: NumberF.Metrics

  @doc "Converts fluid ounces to millilitres."
  @doc group: "Units"
  defdelegate oz_to_ml(oz), to: NumberF.Metrics

  @doc "Converts acres to hectares."
  @doc group: "Units"
  defdelegate acres_to_hectares(acres), to: NumberF.Metrics

  @doc "Converts hectares to acres."
  @doc group: "Units"
  defdelegate hectares_to_acres(hectares), to: NumberF.Metrics

  @doc """
  Converts between arbitrary units from one of the unit tables.

  Unit keys are strings, not atoms.

  ## Examples

      iex> NumberF.convert_units(100, "km", "mi", NumberF.length_units()) |> Float.round(2)
      62.14
  """
  @doc group: "Units"
  defdelegate convert_units(value, from, to, units), to: NumberF.Metrics

  @doc "Length conversion factors, relative to metres."
  @doc group: "Units"
  defdelegate length_units(), to: NumberF.Metrics

  @doc "Weight conversion factors, relative to kilograms."
  @doc group: "Units"
  defdelegate weight_units(), to: NumberF.Metrics

  @doc "Volume conversion factors, relative to litres."
  @doc group: "Units"
  defdelegate volume_units(), to: NumberF.Metrics

  @doc "Area conversion factors, relative to square metres."
  @doc group: "Units"
  defdelegate area_units(), to: NumberF.Metrics

  @doc """
  Adds business days to a date. A negative count subtracts them.

  ## Examples

      iex> NumberF.add_business_days(~D[2024-01-15], -3)
      ~D[2024-01-10]
  """
  @doc group: "Dates"
  defdelegate add_business_days(date, num_days), to: NumberF.DateCalculations

  @doc """
  Returns the next business day after the given date.

  ## Examples

      iex> NumberF.next_business_day(~D[2024-01-12])
      ~D[2024-01-15]
  """
  @doc group: "Dates"
  defdelegate next_business_day(date), to: NumberF.DateCalculations

  @doc """
  Returns the formatting settings for a locale.

  ## Examples

      iex> NumberF.get_locale_settings("en-US").currency_symbol
      "$"
  """
  @doc group: "Internationalization"
  defdelegate get_locale_settings(locale), to: NumberF.I18n

  @doc """
  Parses a locale-formatted number string back into a number.

  ## Examples

      iex> NumberF.parse_number("1.234,56", "de-DE")
      1234.56
  """
  @doc group: "Internationalization"
  defdelegate parse_number(text, locale), to: NumberF.I18n

  @doc "Returns the main and sub unit names for a currency in a given language."
  @doc group: "Internationalization"
  defdelegate get_currency_names(currency_code, language), to: NumberF.I18n

  @doc "Returns metadata for a single NumberF module."
  @doc group: "Introspection"
  defdelegate module_details(name), to: NumberF.Registry

  @doc "Returns metadata for a single function category."
  @doc group: "Introspection"
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
  @doc group: "Introspection"
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
