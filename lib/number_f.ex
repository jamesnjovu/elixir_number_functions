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
  def currency(number, unit \\ "$", precision \\ 2) do
    NumberF.Currency.currency(number, unit, precision)
  end

  def comma_separated(number, precision \\ 2) do
    NumberF.Currency.comma_separated(number, precision)
  end

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
  def randomizer(length, type \\ :all) do
    NumberF.Randomizer.randomizer(length, type)
  end

  def default_password() do
    NumberF.Randomizer.gen_password()
  end

  def to_words(amount, main_currence \\ "Kwacha", sec_current \\ "Ngwee") do
    NumberF.Workers.NumbersToWords.parse(amount, main_currence, sec_current)
  end
end
