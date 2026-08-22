defmodule NumberF.Formatter do
  @moduledoc """
  General formatting utilities for NumberF.
  """

  # Largest first; a new tier is one row rather than another guard clause.
  @abbreviation_tiers [
    {1_000_000_000_000, "T"},
    {1_000_000_000, "B"},
    {1_000_000, "M"},
    {1_000, "K"}
  ]

  @doc """
  Formats phone numbers based on country code.

  ## Parameters
    - `number`: The phone number as a string
    - `country_code`: The country code (default: "ZM" for Zambia)

  ## Examples

      iex> NumberF.Formatter.format_phone("260977123456", "ZM")
      "+260 97 712 3456"

      iex> NumberF.Formatter.format_phone("14155552671", "US")
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
          String.slice(digits, 0, 3) <>
            " " <>
            String.slice(digits, 3, 3) <> " " <> String.slice(digits, 6, 4)
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
          String.slice(digits, 0, 3) <>
            " " <>
            String.slice(digits, 3, 4) <> " " <> String.slice(digits, 7, 4)
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

      iex> NumberF.Formatter.abbreviate_number(1234)
      "1.2K"

      iex> NumberF.Formatter.abbreviate_number(1234567)
      "1.2M"

      iex> NumberF.Formatter.abbreviate_number(1234567890)
      "1.2B"
  """
  def abbreviate_number(number, precision \\ 1) when is_number(number) do
    # Recurse on the magnitude rather than adding negative mirrors of every guard.
    # The old `number >= 1_000` chain never matched a negative, so -5000 came back
    # as "-5000" instead of "-5.0K".
    if number < 0 do
      "-" <> abbreviate_number(-number, precision)
    else
      case Enum.find(@abbreviation_tiers, fn {threshold, _} -> number >= threshold end) do
        nil -> "#{number}"
        {divisor, suffix} -> "#{Float.round(number / divisor, precision)}#{suffix}"
      end
    end
  end

  @doc """
  Converts numbers to ordinals (1st, 2nd, 3rd, etc.).

  ## Parameters
    - `number`: The number to convert

  ## Examples

      iex> NumberF.Formatter.ordinal(1)
      "1st"

      iex> NumberF.Formatter.ordinal(2)
      "2nd"

      iex> NumberF.Formatter.ordinal(3)
      "3rd"

      iex> NumberF.Formatter.ordinal(4)
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

      iex> NumberF.Formatter.to_roman(4)
      "IV"

      iex> NumberF.Formatter.to_roman(42)
      "XLII"

      iex> NumberF.Formatter.to_roman(1999)
      "MCMXCIX"
  """
  # Out-of-range input raises ArgumentError naming the supported range, rather than
  # the FunctionClauseError this module used to leak while the facade's copy of the
  # same function raised ArgumentError.
  def to_roman(number) when is_integer(number) and (number <= 0 or number >= 4000) do
    raise ArgumentError,
          "Roman numerals only support numbers from 1 to 3999, got: #{inspect(number)}"
  end

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

      iex> NumberF.Formatter.from_roman("IV")
      4

      iex> NumberF.Formatter.from_roman("XLII")
      42

      iex> NumberF.Formatter.from_roman("MCMXCIX")
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

  @doc """
  Formats a percentage with specified precision.

  ## Parameters
    - `value`: The value to calculate percentage for
    - `total`: The total value (100%)
    - `precision`: Number of decimal places (default: 2)
    - `options`: Additional options
      - `:symbol`: Whether to include % symbol (default: true)

  ## Examples

      iex> NumberF.Formatter.format_percentage(25, 100)
      "25.0%"

      iex> NumberF.Formatter.format_percentage(1, 3, 2)
      "33.33%"

      iex> NumberF.Formatter.format_percentage(1, 3, 2, symbol: false)
      "33.33"
  """
  def format_percentage(value, total, precision \\ 2, options \\ []) do
    show_symbol = Keyword.get(options, :symbol, true)
    result = value / total * 100
    formatted = Float.round(result, precision)

    if show_symbol do
      "#{formatted}%"
    else
      "#{formatted}"
    end
  end

  @doc """
  Formats a number as a fraction.

  ## Parameters
    - `numerator`: The numerator
    - `denominator`: The denominator
    - `options`: Additional options
      - `:reduce`: Whether to reduce to lowest terms (default: true)
      - `:mixed`: Whether to show as mixed number if improper (default: false)

  ## Examples

      iex> NumberF.Formatter.format_fraction(3, 4)
      "3/4"

      iex> NumberF.Formatter.format_fraction(6, 8)
      "3/4"

      iex> NumberF.Formatter.format_fraction(5, 4, mixed: true)
      "1 1/4"
  """
  def format_fraction(numerator, denominator, options \\ [])
      when is_integer(numerator) and is_integer(denominator) and denominator != 0 do
    reduce = Keyword.get(options, :reduce, true)
    mixed = Keyword.get(options, :mixed, false)

    {num, den} =
      if reduce do
        gcd_val = NumberF.Calculations.gcd(abs(numerator), abs(denominator))
        {div(numerator, gcd_val), div(denominator, gcd_val)}
      else
        {numerator, denominator}
      end

    # Handle negative fractions
    {num, den} =
      if den < 0 do
        {-num, -den}
      else
        {num, den}
      end

    if mixed and abs(num) >= den do
      whole = div(num, den)
      remainder = rem(abs(num), den)

      if remainder == 0 do
        "#{whole}"
      else
        if num < 0 do
          "-#{abs(whole)} #{remainder}/#{den}"
        else
          "#{whole} #{remainder}/#{den}"
        end
      end
    else
      "#{num}/#{den}"
    end
  end

  @doc """
  Formats a decimal as a fraction.

  ## Parameters
    - `decimal`: The decimal number to convert
    - `options`: Additional options
      - `:max_denominator`: Maximum allowed denominator (default: 1000)
      - `:mixed`: Whether to show as mixed number if improper (default: false)

  ## Examples

      iex> NumberF.Formatter.decimal_to_fraction(0.75)
      "3/4"

      iex> NumberF.Formatter.decimal_to_fraction(1.25, mixed: true)
      "1 1/4"
  """
  def decimal_to_fraction(decimal, options \\ []) when is_number(decimal) do
    max_denominator = Keyword.get(options, :max_denominator, 1000)
    mixed = Keyword.get(options, :mixed, false)

    # Handle negative numbers
    sign = if decimal < 0, do: -1, else: 1
    decimal = abs(decimal)

    # Simple approach for common fractions
    {num, den} =
      case decimal do
        0.25 -> {1, 4}
        0.5 -> {1, 2}
        0.75 -> {3, 4}
        0.125 -> {1, 8}
        0.375 -> {3, 8}
        0.625 -> {5, 8}
        0.875 -> {7, 8}
        0.2 -> {1, 5}
        0.4 -> {2, 5}
        0.6 -> {3, 5}
        0.8 -> {4, 5}
        _ -> find_fraction_approximation(decimal, max_denominator)
      end

    # Apply sign
    num = num * sign

    format_fraction(num, den, mixed: mixed)
  end

  @doc """
  Formats a number in scientific notation.

  ## Parameters
    - `number`: The number to format
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.Formatter.scientific_notation(1234567)
      "1.23e6"

      iex> NumberF.Formatter.scientific_notation(0.000123, 3)
      "1.23e-4"
  """
  def scientific_notation(number, precision \\ 2) when is_number(number) do
    if number == 0 do
      "0.0e0"
    else
      exponent = decimal_exponent(number)
      mantissa = Float.round(number / :math.pow(10, exponent), precision)

      "#{mantissa}e#{exponent}"
    end
  end

  @doc """
  Formats a number in engineering notation (exponents are multiples of 3).

  ## Parameters
    - `number`: The number to format
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.Formatter.engineering_notation(1234567)
      "1.23e6"

      iex> NumberF.Formatter.engineering_notation(0.000123)
      "123.0e-6"
  """
  def engineering_notation(number, precision \\ 2) when is_number(number) do
    if number == 0 do
      "0.0e0"
    else
      # floor_div, not div: div/2 truncates toward zero, so an exponent of -4 would
      # give -3 and a mantissa of 0.123 rather than the required 123.0e-6.
      eng_exponent = Integer.floor_div(decimal_exponent(number), 3) * 3
      mantissa = Float.round(number / :math.pow(10, eng_exponent), precision)

      "#{mantissa}e#{eng_exponent}"
    end
  end

  # The base-10 exponent, floored. trunc/1 rounds toward zero, which is correct for
  # |n| >= 1 but off by one below it: log10(0.000123) is -3.91, and the exponent has
  # to be -4, not -3. That single character is what the hardcoded 0.000123 branches
  # in scientific_notation/2 and engineering_notation/2 were compensating for.
  defp decimal_exponent(number) do
    number |> abs() |> :math.log10() |> Float.floor() |> trunc()
  end

  @doc """
  Formats a number with custom prefix and suffix.

  ## Parameters
    - `number`: The number to format
    - `options`: Formatting options
      - `:prefix`: String to prepend (default: "")
      - `:suffix`: String to append (default: "")
      - `:precision`: Number of decimal places (default: 2)
      - `:thousands_separator`: Thousands separator (default: ",")

  ## Examples

      iex> NumberF.Formatter.format_with_units(1234.56, prefix: "$", suffix: " USD")
      "$1,234.56 USD"

      iex> NumberF.Formatter.format_with_units(98.6, suffix: "°F", precision: 1)
      "98.6°F"
  """
  def format_with_units(number, options \\ []) when is_number(number) do
    prefix = Keyword.get(options, :prefix, "")
    suffix = Keyword.get(options, :suffix, "")
    precision = Keyword.get(options, :precision, 2)
    thousands_separator = Keyword.get(options, :thousands_separator, ",")

    # Format the number with thousands separator
    formatted_number =
      NumberF.CustomFormatter.number_to_delimited(number,
        delimiter: thousands_separator,
        precision: precision
      )

    prefix <> formatted_number <> suffix
  end

  # Private helper functions

  defp find_fraction_approximation(decimal, max_denominator) do
    # Use continued fractions to find the best approximation
    find_best_fraction(decimal, max_denominator, 1, 0, 0, 1)
  end

  defp find_best_fraction(target, max_denom, h1, h2, k1, k2) do
    if k1 > max_denom do
      {h2, k2}
    else
      a = trunc(target)
      remainder = target - a

      new_h = a * h1 + h2
      new_k = a * k1 + k2

      if remainder == 0 or new_k > max_denom do
        {new_h, new_k}
      else
        find_best_fraction(1 / remainder, max_denom, new_h, h1, new_k, k1)
      end
    end
  end

  @doc """
  Accounting format: negatives in parentheses rather than with a minus sign.

  ## Examples

      iex> NumberF.Formatter.accounting_format(-1234.56, unit: "$")
      "($1,234.56)"

      iex> NumberF.Formatter.accounting_format(1234.56, unit: "$")
      "$1,234.56"
  """
  def accounting_format(number, options \\ []) when is_number(number) do
    unit = Keyword.get(options, :unit, "")
    precision = Keyword.get(options, :precision, 2)

    formatted =
      number
      |> abs()
      |> NumberF.CustomFormatter.number_to_delimited(precision: precision)

    body = unit <> formatted

    if number < 0, do: "(" <> body <> ")", else: body
  end

  @doc """
  Human-readable byte size.

  Pass `base: :binary` for KiB/MiB units (powers of 1024); the default is SI
  (powers of 1000), which is what storage vendors and most operating systems print.

  ## Examples

      iex> NumberF.Formatter.format_bytes(1_500_000)
      "1.5 MB"

      iex> NumberF.Formatter.format_bytes(1_048_576, base: :binary)
      "1.0 MiB"

      iex> NumberF.Formatter.format_bytes(5_000_000_000_000)
      "5.0 TB"
  """
  @si_units ["B", "kB", "MB", "GB", "TB", "PB", "EB"]
  @binary_units ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB"]

  def format_bytes(bytes, options \\ []) when is_number(bytes) do
    {step, units} =
      case Keyword.get(options, :base, :si) do
        :si -> {1000, @si_units}
        :binary -> {1024, @binary_units}
        other -> raise ArgumentError, "base must be :si or :binary, got: #{inspect(other)}"
      end

    precision = Keyword.get(options, :precision, 1)

    if bytes < 0 do
      "-" <> format_bytes(-bytes, options)
    else
      {value, unit} = scale_bytes(bytes * 1.0, units, step)

      if unit == "B" do
        "#{trunc(value)} B"
      else
        "#{Float.round(value, precision)} #{unit}"
      end
    end
  end

  # A zero hour or minute is noise in a duration, but a duration of exactly zero
  # still has to render something.
  defp drop_zero_parts(parts), do: Enum.reject(parts, fn {value, _label} -> value == 0 end)

  defp scale_bytes(value, [unit], _step), do: {value, unit}
  defp scale_bytes(value, [unit | _rest], step) when value < step, do: {value, unit}
  defp scale_bytes(value, [_unit | rest], step), do: scale_bytes(value / step, rest, step)

  @doc """
  Human-readable duration from a number of seconds.

  Formats: `:short` (default) gives `"1h 2m 5s"`, `:long` gives
  `"1 hour, 2 minutes, 5 seconds"`, `:clock` gives `"01:02:05"`.

  ## Examples

      iex> NumberF.Formatter.format_duration(3725)
      "1h 2m 5s"

      iex> NumberF.Formatter.format_duration(3725, format: :clock)
      "01:02:05"

      iex> NumberF.Formatter.format_duration(90, format: :long)
      "1 minute, 30 seconds"
  """
  def format_duration(seconds, options \\ []) when is_number(seconds) do
    if seconds < 0 do
      "-" <> format_duration(-seconds, options)
    else
      total = trunc(seconds)
      hours = div(total, 3600)
      minutes = total |> rem(3600) |> div(60)
      secs = rem(total, 60)

      case Keyword.get(options, :format, :short) do
        :clock ->
          [hours, minutes, secs]
          |> Enum.map_join(":", &(&1 |> Integer.to_string() |> String.pad_leading(2, "0")))

        :short ->
          parts = drop_zero_parts([{hours, "h"}, {minutes, "m"}, {secs, "s"}])

          if parts == [],
            do: "0s",
            else: Enum.map_join(parts, " ", fn {value, suffix} -> "#{value}#{suffix}" end)

        :long ->
          parts = drop_zero_parts([{hours, "hour"}, {minutes, "minute"}, {secs, "second"}])

          if parts == [],
            do: "0 seconds",
            else: Enum.map_join(parts, ", ", fn {value, word} -> pluralize(value, word) end)

        other ->
          raise ArgumentError, "format must be :short, :long or :clock, got: #{inspect(other)}"
      end
    end
  end

  @doc """
  Rounds to a number of significant figures.

  ## Precision

  Significant figures count from the first non-zero digit, so this is scale
  independent in a way that decimal-place rounding is not: three significant
  figures keeps three meaningful digits whether the value is 1234 or 0.0001234.

  ## Examples

      iex> NumberF.Formatter.significant_figures(1234.5678, 3)
      1230.0

      iex> NumberF.Formatter.significant_figures(0.00012345, 3)
      0.000123
  """
  def significant_figures(number, digits)
      when is_number(number) and is_integer(digits) and digits > 0 do
    if number == 0 do
      0.0
    else
      magnitude = number |> abs() |> :math.log10() |> Float.floor() |> trunc()
      factor = :math.pow(10, digits - 1 - magnitude)

      Float.round(Float.round(number * factor) / factor, max(0, digits - 1 - magnitude))
    end
  end

  @doc """
  Formats to a number of significant figures, preserving trailing zeros.

  ## Examples

      iex> NumberF.Formatter.format_significant(1.5, 4)
      "1.500"
  """
  def format_significant(number, digits)
      when is_number(number) and is_integer(digits) and digits > 0 do
    if number == 0 do
      :erlang.float_to_binary(0.0, decimals: digits - 1)
    else
      magnitude = number |> abs() |> :math.log10() |> Float.floor() |> trunc()
      decimals = max(0, digits - 1 - magnitude)

      number
      |> significant_figures(digits)
      |> :erlang.float_to_binary(decimals: decimals)
    end
  end

  @doc """
  Prefixes a number with an explicit sign.

  ## Examples

      iex> NumberF.Formatter.with_sign(42)
      "+42"

      iex> NumberF.Formatter.with_sign(-42)
      "-42"

      iex> NumberF.Formatter.with_sign(0, zero: " ")
      " 0"
  """
  def with_sign(number, options \\ []) when is_number(number) do
    zero_sign = Keyword.get(options, :zero, "+")

    sign =
      cond do
        number > 0 -> "+"
        number < 0 -> "-"
        true -> zero_sign
      end

    sign <> to_string(abs(number))
  end

  @doc """
  Pads a number to a fixed width.

  ## Examples

      iex> NumberF.Formatter.pad_number(42, 6)
      "    42"

      iex> NumberF.Formatter.pad_number(42, 6, char: "0")
      "000042"

      iex> NumberF.Formatter.pad_number(42, 6, align: :left)
      "42    "
  """
  def pad_number(number, width, options \\ []) when is_number(number) and is_integer(width) do
    char = Keyword.get(options, :char, " ")
    text = to_string(number)

    case Keyword.get(options, :align, :right) do
      :right -> String.pad_leading(text, width, char)
      :left -> String.pad_trailing(text, width, char)
      other -> raise ArgumentError, "align must be :left or :right, got: #{inspect(other)}"
    end
  end

  @doc """
  Pairs a count with a correctly pluralised noun.

  Appends "s" unless an explicit plural is given, which covers the regular cases
  without pretending to know English morphology.

  ## Examples

      iex> NumberF.Formatter.pluralize(1, "item")
      "1 item"

      iex> NumberF.Formatter.pluralize(3, "item")
      "3 items"

      iex> NumberF.Formatter.pluralize(3, "person", "people")
      "3 people"
  """
  def pluralize(count, singular, plural \\ nil) when is_number(count) and is_binary(singular) do
    word = if abs(count) == 1, do: singular, else: plural || singular <> "s"

    "#{count} #{word}"
  end
end
