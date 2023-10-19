defmodule NumberF do
  @moduledoc """
  Documentation for `NumberF`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> NumberF.currency()
      :world

  """
  def currency(number, unit \\ "ZMW", precision \\ 2),
   do: NumberF.Currency.currency(number, unit, precision)

  def comma_separated(number, precision \\ 2),
   do: NumberF.Currency.comma_separated(number, precision)

  @doc """
  Generate random string based on the given legth. It is also possible to generate certain type of randomise string using the options below:
  * :all - generate alphanumeric random string
  * :alpha - generate nom-numeric random string
  * :numeric - generate numeric random string
  * :upcase - generate upper case non-numeric random string
  * :downcase - generate lower case non-numeric random string
  ## Example
      iex> NumberF.randomizer(20) //"Je5QaLj982f0Meb0ZBSK"
  """
  def randomizer(length, type \\ :all),
   do: NumberF.Randomizer.randomizer(length, type)

  def default_password(), do: NumberF.Randomizer.gen_password()

  @doc """
  Convert a number into words:
  ## Example
      iex> NumberF.to_words(20.0)
  """
  def to_words(amount, main_currence \\ "Kwacha", sec_current \\ "Ngwee"),
   do: NumberF.NumbersToWords.parse(amount, main_currence, sec_current)

  @doc """
  Convert a number into words:
  ## Example
      iex> NumberF.to_words(20.0)
  """
  def memory_size_cal(size),
   do: NumberF.Memory.humanize(size)

  def to_int(value) do
    {nun, _} = Integer.parse(value)
    nun
  end

  def to_float(value), do: Number.Conversion.to_float(value)

  def to_decimal(value), do: Number.Conversion.to_decimal(value)

  def to_boolean(value) do
    target = String.downcase(value)

    cond do
      target == "true" || target == "yes" || target == "on" -> true
      target == "false" || target == "no" || target == "off" -> false
      true -> raise ArgumentError, "could not convert #{inspect(value)} to boolean"
    end
  end

  def number_to_delimited(number, options \\ []),
    do: Number.Delimit.number_to_delimited(number, options)
end
