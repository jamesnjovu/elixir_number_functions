defmodule NumberF do
  @moduledoc """
  # NumberF

  A comprehensive utility module for performing various number-related operations in Elixir.

  ## Features

  ### Formatting
  - Format numbers as currency values with custom units
  - Create comma-separated number formats
  - Custom number delimiter formatting

  ### Conversion
  - Convert numbers to words representation
  - Convert between various numeric types (int, float, decimal)
  - Convert strings to boolean values

  ### Generation
  - Generate random strings with customizable properties
  - Create default passwords with predefined patterns

  ### Utilities
  - Convert memory sizes to human-readable formats
  - Sum decimal values, including in nested lists

  ## Examples

  ```elixir
  # Currency formatting
  NumberF.currency(1234.567)                    # => "ZMW 1,234.57"
  NumberF.currency(1234.567, "USD", 2)          # => "USD 1,234.57"
  NumberF.comma_separated(1234567.89)           # => "1,234,567.89"

  # Numbers to words
  NumberF.to_words(20.0)                        # => "Twenty Kwacha and zero Ngwee"
  NumberF.to_words(42.75, "Dollars", "Cents")   # => "Forty Two Dollars And Seventy Five Cents"

  # Random generation
  NumberF.randomizer(10)                        # => "a1B2c3D4e5"
  NumberF.default_password()                    # => "Dev@2308"

  # Memory size humanization
  NumberF.memory_size_cal(1048576)              # => "1.0 MB"

  # Type conversions
  NumberF.to_int("123")                         # => 123
  NumberF.to_float("123.45")                    # => 123.45
  NumberF.to_decimal("123.45")                  # => #Decimal<123.45>
  NumberF.to_boolean("yes")                     # => true

  # Custom formatting
  NumberF.number_to_delimited(1234567.89, delimiter: ".", separator: ",") # => "1.234.567,89"
  ```
  """

  @doc """
  Formats a number into currency with the specified unit and precision.

  ## Parameters
    - `number`: The number to format
    - `unit`: The currency unit (default: "ZMW")
    - `precision`: Decimal places (default: 2)

  ## Examples

      iex> NumberF.currency(1234.567)
      "ZMW 1,234.57"

      iex> NumberF.currency(1234.567, "USD", 2)
      "USD 1,234.57"

      iex> NumberF.currency(nil, "USD", 2)
      nil
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

  ## Parameters
    - `amount`: The number to convert
    - `main_currency`: The main currency name (default: "Kwacha")
    - `sec_currency`: The secondary currency name (default: "Ngwee")

  ## Examples

      iex> NumberF.to_words(20.0)
      "Twenty Kwacha and zero Ngwee"

      iex> NumberF.to_words(42.75, "Dollars", "Cents")
      "Forty Two Dollars And Seventy Five Cents"

      iex> NumberF.to_words(0, "Euros", "Cents")
      "zero Euros"
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
  def to_float(value), do: Number.Conversion.to_float(value)

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
  def to_decimal(value), do: Number.Conversion.to_decimal(value)

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
    do: Number.Delimit.number_to_delimited(number, options)

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

  ## Parameters
    - `principal`: The principal amount
    - `rate`: The annual interest rate as a decimal (e.g., 0.05 for 5%)
    - `time`: The time period in years
    - `frequency`: Number of times interest is compounded per year (default: 1)

  ## Examples

      iex> NumberF.compound_interest(1000, 0.05, 2)
      102.5

      iex> NumberF.compound_interest(1000, 0.05, 2, 12)
      104.94
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

  ## Parameters
    - `numbers`: A list of numbers

  ## Examples

      iex> NumberF.mean([1, 2, 3, 4, 5])
      3.0
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
  def payment_due_date(invoice_date, terms_days \\ 30) do
    Date.add(invoice_date, terms_days)
  end
end
