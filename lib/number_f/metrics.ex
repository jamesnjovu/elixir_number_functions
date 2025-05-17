defmodule NumberF.Metrics do
  @moduledoc """
  Functions for handling unit conversions between different measurement systems.
  """

  @doc """
  Converts inches to centimeters.

  ## Parameters
    - `inches`: The length in inches

  ## Examples

      iex> NumberF.Metrics.inches_to_cm(10)
      25.4

      iex> NumberF.Metrics.inches_to_cm(3.5)
      8.89
  """
  def inches_to_cm(inches) when is_number(inches) do
    inches * 2.54
  end

  @doc """
  Converts centimeters to inches.

  ## Parameters
    - `cm`: The length in centimeters

  ## Examples

      iex> NumberF.Metrics.cm_to_inches(25.4)
      10.0

      iex> NumberF.Metrics.cm_to_inches(8.89)
      3.5
  """
  def cm_to_inches(cm) when is_number(cm) do
    cm / 2.54
  end

  @doc """
  Converts miles to kilometers.

  ## Parameters
    - `miles`: The distance in miles

  ## Examples

      iex> NumberF.Metrics.miles_to_km(10)
      16.09
  """
  def miles_to_km(miles) when is_number(miles) do
    Float.round(miles * 1.60934, 2)
  end

  @doc """
  Converts kilometers to miles.

  ## Parameters
    - `km`: The distance in kilometers

  ## Examples

      iex> NumberF.Metrics.km_to_miles(16.09)
      10.0
  """
  def km_to_miles(km) when is_number(km) do
    Float.round(km / 1.60934, 2)
  end

  @doc """
  Converts pounds to kilograms.

  ## Parameters
    - `pounds`: The weight in pounds

  ## Examples

      iex> NumberF.Metrics.pounds_to_kg(10)
      4.54
  """
  def pounds_to_kg(pounds) when is_number(pounds) do
    Float.round(pounds * 0.453592, 2)
  end

  @doc """
  Converts kilograms to pounds.

  ## Parameters
    - `kg`: The weight in kilograms

  ## Examples

      iex> NumberF.Metrics.kg_to_pounds(4.54)
      10.01
  """
  def kg_to_pounds(kg) when is_number(kg) do
    Float.round(kg / 0.453592, 2)
  end

  @doc """
  Converts Fahrenheit to Celsius.

  ## Parameters
    - `fahrenheit`: The temperature in Fahrenheit

  ## Examples

      iex> NumberF.Metrics.fahrenheit_to_celsius(32)
      0.0

      iex> NumberF.Metrics.fahrenheit_to_celsius(212)
      100.0
  """
  def fahrenheit_to_celsius(fahrenheit) when is_number(fahrenheit) do
    Float.round((fahrenheit - 32) * 5 / 9, 2)
  end

  @doc """
  Converts Celsius to Fahrenheit.

  ## Parameters
    - `celsius`: The temperature in Celsius

  ## Examples

      iex> NumberF.Metrics.celsius_to_fahrenheit(0)
      32.0

      iex> NumberF.Metrics.celsius_to_fahrenheit(100)
      212.0
  """
  def celsius_to_fahrenheit(celsius) when is_number(celsius) do
    Float.round(celsius * 9 / 5 + 32, 2)
  end

  @doc """
  Converts fluid ounces to milliliters.

  ## Parameters
    - `oz`: The volume in fluid ounces

  ## Examples

      iex> NumberF.Metrics.oz_to_ml(1)
      29.57
  """
  def oz_to_ml(oz) when is_number(oz) do
    Float.round(oz * 29.5735, 2)
  end

  @doc """
  Converts milliliters to fluid ounces.

  ## Parameters
    - `ml`: The volume in milliliters

  ## Examples

      iex> NumberF.Metrics.ml_to_oz(29.57)
      1.0
  """
  def ml_to_oz(ml) when is_number(ml) do
    Float.round(ml / 29.5735, 2)
  end

  @doc """
  Converts acres to hectares.

  ## Parameters
    - `acres`: The area in acres

  ## Examples

      iex> NumberF.Metrics.acres_to_hectares(2.47)
      1.0
  """
  def acres_to_hectares(acres) when is_number(acres) do
    Float.round(acres * 0.404686, 2)
  end

  @doc """
  Converts hectares to acres.

  ## Parameters
    - `hectares`: The area in hectares

  ## Examples

      iex> NumberF.Metrics.hectares_to_acres(1)
      2.47
  """
  def hectares_to_acres(hectares) when is_number(hectares) do
    Float.round(hectares / 0.404686, 2)
  end

  @doc """
  Converts between different metric units of the same type.

  ## Parameters
    - `value`: The value to convert
    - `from_unit`: The source unit
    - `to_unit`: The target unit
    - `conversion_map`: A map of conversion factors

  ## Examples

      iex> conversion_map = %{
      ...>   "mm" => 0.001,
      ...>   "cm" => 0.01,
      ...>   "m" => 1,
      ...>   "km" => 1000
      ...> }
      iex> NumberF.Metrics.convert_units(5, "cm", "m", conversion_map)
      0.05
  """
  def convert_units(value, from_unit, to_unit, conversion_map) when is_number(value) do
    from_factor = Map.get(conversion_map, from_unit)
    to_factor = Map.get(conversion_map, to_unit)

    if from_factor && to_factor do
      value * from_factor / to_factor
    else
      raise ArgumentError, "Unknown unit provided"
    end
  end

  # Predefined conversion maps
  def length_units do
    %{
      "mm" => 0.001,
      "cm" => 0.01,
      "dm" => 0.1,
      "m" => 1,
      "km" => 1000,
      "in" => 0.0254,
      "ft" => 0.3048,
      "yd" => 0.9144,
      "mi" => 1609.344
    }
  end

  def weight_units do
    %{
      "mg" => 0.000001,
      "g" => 0.001,
      "kg" => 1,
      "t" => 1000,
      "oz" => 0.0283495,
      "lb" => 0.453592,
      "st" => 6.35029
    }
  end

  def volume_units do
    %{
      "ml" => 0.001,
      "cl" => 0.01,
      "dl" => 0.1,
      "l" => 1,
      "m3" => 1000,
      "fl_oz" => 0.0295735,
      "pt" => 0.473176,
      "qt" => 0.946353,
      "gal" => 3.78541
    }
  end

  def area_units do
    %{
      "mm2" => 0.000001,
      "cm2" => 0.0001,
      "dm2" => 0.01,
      "m2" => 1,
      "a" => 100,
      "ha" => 10000,
      "km2" => 1_000_000,
      "in2" => 0.00064516,
      "ft2" => 0.092903,
      "yd2" => 0.836127,
      "ac" => 4046.86,
      "mi2" => 2_589_988.11
    }
  end
end
