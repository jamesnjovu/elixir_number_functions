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
  - **Formatting**: `NumberF.Currency`, `NumberF.Formatter`, `NumberF.CustomFormatter`, `NumberF.Currencies`
  - **Conversion**: `NumberF.Metrics`, `NumberF.NumbersToWords`, `NumberF.NumberToWord`
  - **Validation**: `NumberF.Validation`
  - **Utilities**: `NumberF.Memory`, `NumberF.Randomizer`, `NumberF.Helper`
  - **Date**: `NumberF.DateCalculations`
  - **I18n**: `NumberF.I18n`

  While specific functions can be accessed through their respective modules,
  most common functionality is available directly from the main `NumberF` module
  for convenience.

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
  def currency(number, unit \\ "ZMW", precision \\ 2),
    do: NumberF.Currency.currency(number, unit, precision)

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
  def comma_separated(number, precision \\ 2),
    do: NumberF.Currency.comma_separated(number, precision)

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

      iex> NumberF.randomizer(10)
      "a1B2c3D4e5" # Example output, actual value will vary

      iex> NumberF.randomizer(5, :numeric)
      "23579" # Example output, actual value will vary

      iex> NumberF.randomizer(6, :upcase)
      "ABCDEF" # Example output, actual value will vary
  """
  def randomizer(length, type \\ :all),
    do: NumberF.Randomizer.randomizer(length, type)

  @doc """
  Generates a default password with pre-defined complexity.
  The pattern is: capitalized 3-letter string + @ + 4 random digits.

  ## Examples

      iex> NumberF.default_password()
      "Dev@2308" # Example output, actual value will vary

  """
  def default_password(), do: NumberF.Randomizer.gen_password()

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
      "Twenty Kwacha and zero Ngwee"

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
  def to_words(amount, main_currence \\ "Kwacha", sec_current \\ "Ngwee"),
    do: NumberF.NumbersToWords.parse(amount, main_currence, sec_current)

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
  def memory_size_cal(size),
    do: NumberF.Memory.humanize(size)

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
  def to_int(value) do
    {nun, _} = Integer.parse(value)
    nun
  end

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
  def to_float(value), do: NumberF.CustomFormatter.to_float(value)

  @doc """
  Converts a value to a decimal.

  ## Parameters
    - `value`: The value to convert (string or number)

  ## Examples

      iex> NumberF.to_decimal("123.45")
      #Decimal<123.45>

      iex> NumberF.to_decimal(123)
      #Decimal<123>
  """
  def to_decimal(value), do: NumberF.CustomFormatter.to_decimal(value)

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
  def to_boolean(value) do
    target = String.downcase(value)

    cond do
      target == "true" || target == "yes" || target == "on" -> true
      target == "false" || target == "no" || target == "off" -> false
      true -> raise ArgumentError, "could not convert #{inspect(value)} to boolean"
    end
  end

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
  def number_to_delimited(number, options \\ []),
    do: NumberF.CustomFormatter.number_to_delimited(number, options)

  @doc """
  Sums a list of decimal numbers.

  ## Parameters
    - `list`: A list of decimal values, potentially nested

  ## Examples

      iex> sum_decimal([Decimal.new("1.2"), Decimal.new("3.4"), [Decimal.new("5.6")]])
      #Decimal<10.2>

      iex> sum_decimal([])
      #Decimal<0>

  This function flattens any nested lists, then uses `Enum.reduce/3` to sum all the decimal values.
  """
  def sum_decimal(list) do
    List.flatten(list)
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1, &2))
  end

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
  def percentage(value, total, precision \\ 2) do
    result = value / total * 100
    Float.round(result, precision)
  end

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
  def round_to_nearest(value, nearest \\ 1.0) do
    round(value / nearest) * nearest
  end

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
  def in_range?(value, min, max) when is_number(value) and is_number(min) and is_number(max) do
    value >= min and value <= max
  end

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
  def simple_interest(principal, rate, time)
      when is_number(principal) and is_number(rate) and is_number(time) do
    principal * rate * time
  end

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
      4693.28  # Quarterly compounding (4 times per year)

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
  def compound_interest(principal, rate, time, frequency \\ 1)
      when is_number(principal) and is_number(rate) and is_number(time) and is_number(frequency) do
    result = principal * :math.pow(1 + rate / frequency, frequency * time) - principal
    Float.round(result, 2)
  end

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
  def calculate_emi(principal, rate, term_months)
      when is_number(principal) and is_number(rate) and is_number(term_months) and term_months > 0 do
    monthly_rate = rate / 12

    emi =
      principal * monthly_rate * :math.pow(1 + monthly_rate, term_months) /
        (:math.pow(1 + monthly_rate, term_months) - 1)

    Float.round(emi, 2)
  end

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
  def convert_currency(amount, from_rate, to_rate)
      when is_number(amount) and is_number(from_rate) and is_number(to_rate) and from_rate > 0 and
             to_rate > 0 do
    amount * to_rate / from_rate
  end

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
  def mean([]), do: nil

  def mean(numbers) when is_list(numbers) do
    total = Enum.sum(numbers)
    count = length(numbers)
    total / count
  end

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
  def median([]), do: nil

  def median(numbers) when is_list(numbers) do
    sorted = Enum.sort(numbers)
    count = length(sorted)

    if rem(count, 2) == 0 do
      # Even number of elements
      middle_idx = div(count, 2)
      (Enum.at(sorted, middle_idx - 1) + Enum.at(sorted, middle_idx)) / 2
    else
      # Odd number of elements
      Enum.at(sorted, div(count, 2))
    end
  end

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
  def mode([]), do: []

  def mode(numbers) when is_list(numbers) do
    frequencies =
      Enum.reduce(numbers, %{}, fn num, acc ->
        Map.update(acc, num, 1, &(&1 + 1))
      end)

    {_count, max_freq} = Enum.max_by(frequencies, fn {_num, count} -> count end)

    Enum.filter(frequencies, fn {_num, count} -> count == max_freq end)
    |> Enum.map(fn {num, _count} -> num end)
    |> Enum.sort()
  end

  @doc """
  Calculates standard deviation of a dataset.

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.standard_deviation([2, 4, 4, 4, 5, 5, 7, 9])
      2.0
  """
  def standard_deviation([]), do: nil
  def standard_deviation([_single]), do: 0.0

  def standard_deviation(numbers) when is_list(numbers) do
    avg = mean(numbers)

    variance =
      Enum.reduce(numbers, 0, fn num, sum ->
        sum + :math.pow(num - avg, 2)
      end) / (length(numbers) - 1)

    :math.sqrt(variance)
  end

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
  def is_valid_number?(str) when is_binary(str) do
    case Float.parse(str) do
      {_num, ""} -> true
      _ -> false
    end
  end

  def is_valid_number?(_), do: false

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
  def is_valid_integer?(str) when is_binary(str) do
    case Integer.parse(str) do
      {_num, ""} -> true
      _ -> false
    end
  end

  def is_valid_integer?(_), do: false

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
  def is_valid_credit_card?(number, type \\ :any)

  def is_valid_credit_card?(number, type) when is_binary(number) do
    # Remove any spaces or dashes
    cleaned = String.replace(number, ~r/[\s-]/, "")

    # Check if all characters are digits
    if Regex.match?(~r/^\d+$/, cleaned) do
      # Validate card type by pattern
      card_valid? =
        case type do
          :visa -> Regex.match?(~r/^4[0-9]{12}(?:[0-9]{3})?$/, cleaned)
          :mastercard -> Regex.match?(~r/^5[1-5][0-9]{14}$/, cleaned)
          :amex -> Regex.match?(~r/^3[47][0-9]{13}$/, cleaned)
          :discover -> Regex.match?(~r/^6(?:011|5[0-9]{2})[0-9]{12}$/, cleaned)
          :any -> true
        end

      if card_valid? do
        luhn_valid?(cleaned)
      else
        false
      end
    else
      false
    end
  end

  def is_valid_credit_card?(_, _), do: false

  # Luhn algorithm implementation
  defp luhn_valid?(number) do
    digits = String.graphemes(number) |> Enum.map(&String.to_integer/1)

    # Double every second digit from right to left
    doubled =
      digits
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn {digit, i} ->
        if rem(i, 2) == 1 do
          case digit * 2 do
            n when n > 9 -> n - 9
            n -> n
          end
        else
          digit
        end
      end)
      |> Enum.sum()

    rem(doubled, 10) == 0
  end

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
  def format_phone(number, country_code \\ "ZM") when is_binary(number) do
    # Remove any non-digit characters
    digits = String.replace(number, ~r/\D/, "")

    case country_code do
      "ZM" ->
        if String.starts_with?(digits, "260") do
          "+260 " <>
            String.slice(digits, 3, 2) <>
            " " <>
            String.slice(digits, 5, 3) <> " " <> String.slice(digits, 8, 4)
        else
          "0" <>
            String.slice(digits, 0, 2) <>
            " " <>
            String.slice(digits, 2, 3) <> " " <> String.slice(digits, 5, 4)
        end

      "US" ->
        if String.starts_with?(digits, "1") and String.length(digits) == 11 do
          "+1 (" <>
            String.slice(digits, 1, 3) <>
            ") " <>
            String.slice(digits, 4, 3) <> "-" <> String.slice(digits, 7, 4)
        else
          "(" <>
            String.slice(digits, 0, 3) <>
            ") " <>
            String.slice(digits, 3, 3) <> "-" <> String.slice(digits, 6, 4)
        end

      "UK" ->
        if String.starts_with?(digits, "44") do
          "+44 " <>
            String.slice(digits, 2, 2) <>
            " " <>
            String.slice(digits, 4, 4) <> " " <> String.slice(digits, 8, 4)
        else
          "0" <>
            String.slice(digits, 0, 2) <>
            " " <>
            String.slice(digits, 2, 4) <> " " <> String.slice(digits, 6, 4)
        end

      _ ->
        # Generic international format
        "+" <> digits
    end
  end

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
  def abbreviate_number(number, precision \\ 1) when is_number(number) do
    cond do
      number >= 1_000_000_000 ->
        "#{Float.round(number / 1_000_000_000, precision)}B"

      number >= 1_000_000 ->
        "#{Float.round(number / 1_000_000, precision)}M"

      number >= 1_000 ->
        "#{Float.round(number / 1_000, precision)}K"

      true ->
        "#{number}"
    end
  end

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
  def ordinal(number) when is_integer(number) and number > 0 do
    suffix =
      cond do
        rem(number, 100) in [11, 12, 13] -> "th"
        rem(number, 10) == 1 -> "st"
        rem(number, 10) == 2 -> "nd"
        rem(number, 10) == 3 -> "rd"
        true -> "th"
      end

    "#{number}#{suffix}"
  end

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
  def to_roman(number) when is_integer(number) and number > 0 and number < 4000 do
    roman_map = [
      {1000, "M"},
      {900, "CM"},
      {500, "D"},
      {400, "CD"},
      {100, "C"},
      {90, "XC"},
      {50, "L"},
      {40, "XL"},
      {10, "X"},
      {9, "IX"},
      {5, "V"},
      {4, "IV"},
      {1, "I"}
    ]

    {_num, result} =
      Enum.reduce(roman_map, {number, ""}, fn {val, rom}, {num, acc} ->
        count = div(num, val)
        remainder = rem(num, val)
        {remainder, acc <> String.duplicate(rom, count)}
      end)

    result
  end

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
  def from_roman(roman) when is_binary(roman) do
    chars = String.graphemes(roman)

    values = %{
      "I" => 1,
      "V" => 5,
      "X" => 10,
      "L" => 50,
      "C" => 100,
      "D" => 500,
      "M" => 1000
    }

    {result, _} =
      Enum.reduce(chars, {0, 0}, fn char, {sum, prev} ->
        current = Map.get(values, char, 0)

        # If current value is greater than previous, subtract twice the previous
        # (we already added it once in the previous iteration)
        if current > prev and prev > 0 do
          {sum - prev * 2 + current, current}
        else
          {sum + current, current}
        end
      end)

    result
  end

  ### DATE-BASED CALCULATIONS ###

  @doc """
  Calculates age based on birth date.

  ## Parameters
    - `birth_date`: Birth date as Date struct

  ## Examples

      iex> birth_date = ~D[1990-01-15]
      iex> age = NumberF.calculate_age(birth_date)
      # Returns the current age based on today's date
  """
  def calculate_age(birth_date) do
    today = Date.utc_today()
    years = today.year - birth_date.year

    # Adjust if birthday hasn't occurred yet this year
    if Date.compare(
         %{today | year: today.year - years},
         birth_date
       ) == :lt do
      years - 1
    else
      years
    end
  end

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
  def payment_due_date(invoice_date, terms_days \\ 30)

  def payment_due_date(invoice_date, terms_days) do
    Date.add(invoice_date, terms_days)
  end

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
  def inches_to_cm(inches), do: NumberF.Metrics.inches_to_cm(inches)

  @doc """
  Converts centimeters to inches.

  ## Parameters
    - `cm`: The length in centimeters

  ## Examples

      iex> NumberF.cm_to_inches(25.4)
      10.0
  """
  def cm_to_inches(cm), do: NumberF.Metrics.cm_to_inches(cm)

  @doc """
  Converts miles to kilometers.

  ## Parameters
    - `miles`: The distance in miles

  ## Examples

      iex> NumberF.miles_to_km(10)
      16.09
  """
  def miles_to_km(miles), do: NumberF.Metrics.miles_to_km(miles)

  @doc """
  Converts kilometers to miles.

  ## Parameters
    - `km`: The distance in kilometers

  ## Examples

      iex> NumberF.km_to_miles(16.09)
      10.0
  """
  def km_to_miles(km), do: NumberF.Metrics.km_to_miles(km)

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
  def fahrenheit_to_celsius(fahrenheit), do: NumberF.Metrics.fahrenheit_to_celsius(fahrenheit)

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
  def celsius_to_fahrenheit(celsius), do: NumberF.Metrics.celsius_to_fahrenheit(celsius)

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
  def round_with_precision(number, precision \\ 2),
    do: NumberF.Precision.round_with_precision(number, precision)

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
  def bankers_round(number, precision \\ 2),
    do: NumberF.Precision.bankers_round(number, precision)

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
  def approximately_equal(a, b, epsilon \\ 1.0e-10),
    do: NumberF.Precision.approximately_equal(a, b, epsilon)

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
  def calculate_vat(amount, rate, included \\ false),
    do: NumberF.Tax.calculate_vat(amount, rate, included)

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
  def calculate_sales_tax(amount, rate, options \\ []),
    do: NumberF.Tax.calculate_sales_tax(amount, rate, options)

  @doc """
  Returns common VAT rates for different countries.

  ## Examples

      iex> NumberF.vat_rates()["UK"]
      0.2

      iex> NumberF.vat_rates()["Germany"]
      0.19
  """
  def vat_rates, do: NumberF.Tax.vat_rates()

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
  def format_number(number, locale, options \\ []),
    do: NumberF.I18n.format_number(number, locale, options)

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
  - `NumberF.get_locale_settings/1`: Get formatting rules for a locale
  - `NumberF.spell_number/3`: Spell out numbers in different languages

  See also: `NumberF.I18n` for more internationalization functions.
  """
  def format_currency(number, locale, options \\ []),
    do: NumberF.I18n.format_currency(number, locale, options)

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
  def spell_number(number, language, options \\ []),
    do: NumberF.I18n.spell_number(number, language, options)

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
  def currency_data, do: NumberF.Currencies.currency_data()

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
  def get_currency(currency_code), do: NumberF.Currencies.get_currency(currency_code)

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
  def format_with_currency(number, currency_code, options \\ []),
    do: NumberF.Currencies.format(number, currency_code, options)

  ### REGISTRY AND INFORMATION ###

  @doc """
  Returns information about all NumberF modules.

  ## Examples

      iex> NumberF.modules() |> Enum.map(& &1.name) |> Enum.take(3)
      ["NumberF", "NumberF.Registry", "NumberF.Currency"]
  """
  def modules, do: NumberF.Registry.modules()

  @doc """
  Returns information about NumberF modules of a specific type.

  ## Parameters
    - `type`: The module type (e.g., :formatting, :calculation)

  ## Examples

      iex> NumberF.modules_by_type(:formatting) |> Enum.map(& &1.name)
      ["NumberF.Currency", "NumberF.CustomFormatter", "NumberF.Formatter", "NumberF.Currencies"]
  """
  def modules_by_type(type), do: NumberF.Registry.modules_by_type(type)

  @doc """
  Returns all function categories available in NumberF.

  ## Examples

      iex> NumberF.function_categories() |> Enum.map(& &1.name) |> Enum.take(3)
      ["Formatting", "Conversion", "Generation"]
  """
  def function_categories, do: NumberF.Registry.function_categories()

  @doc """
  Returns a markdown documentation of all NumberF modules and functions.

  ## Examples

      iex> markdown = NumberF.documentation()
      iex> String.starts_with?(markdown, "# NumberF Library")
      true
  """
  def documentation, do: NumberF.Registry.to_markdown()

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
  def factorial(n) when n >= 0, do: NumberF.Calculations.factorial(n)

  @doc """
  Calculates combinations (n choose k).

  ## Parameters
    - `n`: The total number of items
    - `k`: The number of items to choose

  ## Examples

      iex> NumberF.combinations(5, 2)
      10.0

      iex> NumberF.combinations(10, 3)
      120.0
  """
  def combinations(n, k) when k <= n, do: NumberF.Calculations.combinations(n, k)

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
  def gcd(a, b), do: NumberF.Calculations.gcd(a, b)

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
  def lcm(a, b), do: NumberF.Calculations.lcm(a, b)

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
  def is_prime?(n), do: NumberF.Calculations.is_prime?(n)

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
  def interpolate(x, x0, y0, x1, y1), do: NumberF.Calculations.interpolate(x, x0, y0, x1, y1)

  @doc """
  Converts degrees to radians.

  ## Parameters
    - `degrees`: The angle in degrees

  ## Examples

      iex> NumberF.to_radians(180)
      3.141592653589793
  """
  def to_radians(degrees), do: NumberF.Calculations.to_radians(degrees)

  @doc """
  Converts radians to degrees.

  ## Parameters
    - `radians`: The angle in radians

  ## Examples

      iex> NumberF.to_degrees(3.14159)
      180.0
  """
  def to_degrees(radians), do: NumberF.Calculations.to_degrees(radians)

  ### EXTENDED STATISTICS FUNCTIONS ###

  @doc """
  Calculates the variance of a dataset.

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.variance([2, 4, 4, 4, 5, 5, 7, 9])
      4.0
  """
  def variance(numbers), do: NumberF.Statistics.variance(numbers)

  @doc """
  Calculates the range (difference between max and min values) of a dataset.

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.range([2, 4, 4, 4, 5, 5, 7, 9])
      7.0
  """
  def range(numbers), do: NumberF.Statistics.range(numbers)

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
  def days_between(date1, date2), do: NumberF.DateCalculations.days_between(date1, date2)

  @doc """
  Calculates the number of business days between two dates.

  ## Parameters
    - `date1`: The first date
    - `date2`: The second date

  ## Examples

      iex> NumberF.business_days_between(~D[2023-01-02], ~D[2023-01-08])
      5
  """
  def business_days_between(date1, date2),
    do: NumberF.DateCalculations.business_days_between(date1, date2)

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
  def is_business_day?(date), do: NumberF.DateCalculations.is_business_day?(date)

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
      version: "0.2.0",
      modules: NumberF.Registry.modules(),
      function_categories: NumberF.Registry.function_categories()
    }
  end
end
