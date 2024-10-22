defmodule NumberF do
 @moduledoc """
  `NumberF` is a utility module for performing various number-related operations such as formatting currency, generating random strings, converting numbers to words, and more.
  """

  @doc """
  Formats a number into currency with the specified unit and precision.

  ## Parameters
    - `number`: The number to format.
    - `unit`: The currency unit (default: "ZMW").
    - `precision`: Decimal places (default: 2).

  ## Examples

      iex> NumberF.currency(1234.567)
      "ZMW 1,234.57"

  """
  def currency(number, unit \\ "ZMW", precision \\ 2),
   do: NumberF.Currency.currency(number, unit, precision)

  @doc """
  Formats a number into comma-separated format with the specified precision.

  ## Parameters
    - `number`: The number to format.
    - `precision`: Decimal places (default: 2).

  ## Examples

      iex> NumberF.comma_separated(1234567.89)
      "1,234,567.89"

  """
  def comma_separated(number, precision \\ 2),
   do: NumberF.Currency.comma_separated(number, precision)


  @doc """
  Generates a random string of the specified length.

  ## Parameters
    - `length`: The length of the string.
    - `type`: Type of string, with options:
      - `:all` (alphanumeric)
      - `:alpha` (alphabetical)
      - `:numeric` (numbers)
      - `:upcase` (uppercase)
      - `:downcase` (lowercase)

  ## Examples

      iex> NumberF.randomizer(10)
      "a1B2c3D4e5"

  """
  def randomizer(length, type \\ :all),
   do: NumberF.Randomizer.randomizer(length, type)

  @doc """
  Generates a default password with pre-defined complexity.

  ## Examples

      iex> NumberF.default_password()
      "Dev@2308"

  """
  def default_password(), do: NumberF.Randomizer.gen_password()

   @doc """
  Converts a number into words.

  ## Parameters
    - `amount`: The number to convert.
    - `main_currence`: The main currency (default: "Kwacha").
    - `sec_current`: The secondary currency (default: "Ngwee").

  ## Examples

      iex> NumberF.to_words(20.0)
      "Twenty Kwacha and zero Ngwee"

  """
  def to_words(amount, main_currence \\ "Kwacha", sec_current \\ "Ngwee"),
   do: NumberF.NumbersToWords.parse(amount, main_currence, sec_current)

  @doc """
  Converts a memory size to a human-readable format.

  ## Parameters
    - `size`: The size in bytes.

  ## Examples

      iex> NumberF.memory_size_cal(1048576)
      "1 MB"

  """
  def memory_size_cal(size),
   do: NumberF.Memory.humanize(size)

  @doc """
  Converts a string to an integer.

  ## Parameters
    - `value`: The string value to convert.

  ## Examples

      iex> NumberF.to_int("123")
      123

  """
  def to_int(value) do
    {nun, _} = Integer.parse(value)
    nun
  end


  @doc """
  Converts a value to a float.

  ## Parameters
    - `value`: The value to convert.

  ## Examples

      iex> NumberF.to_float("123.45")
      123.45

  """
  def to_float(value), do: Number.Conversion.to_float(value)

  @doc """
  Converts a value to a decimal.

  ## Parameters
    - `value`: The value to convert.

  ## Examples

      iex> NumberF.to_decimal("123.45")
      #Decimal<123.45>

  """
  def to_decimal(value), do: Number.Conversion.to_decimal(value)

  @doc """
  Converts a string to a boolean value.

  ## Parameters
    - `value`: The string value to convert. It accepts `true`, `yes`, `on` for true, and `false`, `no`, `off` for false.

  ## Examples

      iex> NumberF.to_boolean("true")
      true

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
    - `number`: The number to format.
    - `options`: Keyword options for formatting (e.g., delimiter, separator).

  ## Examples

      iex> NumberF.number_to_delimited(1234567.89, delimiter: ".", separator: ",")
      "1.234.567,89"

  """
  def number_to_delimited(number, options \\ []),
    do: Number.Delimit.number_to_delimited(number, options)

  @doc """
  Sums a list of decimal numbers.

  ## Parameters
    - `list`: A list of decimal values, potentially nested.

  ## Examples

      iex> sum_decimal([Decimal.new(1.2), Decimal.new(3.4), [Decimal.new(5.6)]])
      #Decimal<10.2>

  This function flattens any nested lists, then uses `Enum.reduce/3` to sum all the decimal values.
  """
  def sum_decimal(list) do
    List.flatten(list)
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1, &2))
  end
end
