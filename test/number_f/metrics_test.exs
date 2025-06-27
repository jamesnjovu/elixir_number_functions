defmodule NumberF.MetricsTest do
  use ExUnit.Case
  doctest NumberF.Metrics

  describe "length conversions" do
    test "inches_to_cm/1" do
      assert NumberF.Metrics.inches_to_cm(10) == 25.4
      assert NumberF.Metrics.inches_to_cm(1) == 2.54
    end

    test "cm_to_inches/1" do
      assert NumberF.Metrics.cm_to_inches(25.4) == 10.0
      assert NumberF.Metrics.cm_to_inches(2.54) == 1.0
    end
  end

  describe "distance conversions" do
    test "miles_to_km/1" do
      assert NumberF.Metrics.miles_to_km(10) == 16.09
      assert NumberF.Metrics.miles_to_km(1) == 1.61
    end

    test "km_to_miles/1" do
      assert NumberF.Metrics.km_to_miles(16.09) == 10.0
      assert NumberF.Metrics.km_to_miles(1.61) == 1.0
    end
  end

  describe "weight conversions" do
    test "pounds_to_kg/1" do
      assert NumberF.Metrics.pounds_to_kg(10) == 4.54
      assert NumberF.Metrics.pounds_to_kg(1) == 0.45
    end

    test "kg_to_pounds/1" do
      assert NumberF.Metrics.kg_to_pounds(4.54) == 10.01
      assert NumberF.Metrics.kg_to_pounds(1) == 2.2
    end
  end

  describe "temperature conversions" do
    test "fahrenheit_to_celsius/1" do
      assert NumberF.Metrics.fahrenheit_to_celsius(32) == 0.0
      assert NumberF.Metrics.fahrenheit_to_celsius(212) == 100.0
      assert NumberF.Metrics.fahrenheit_to_celsius(68) == 20.0
    end

    test "celsius_to_fahrenheit/1" do
      assert NumberF.Metrics.celsius_to_fahrenheit(0) == 32.0
      assert NumberF.Metrics.celsius_to_fahrenheit(100) == 212.0
      assert NumberF.Metrics.celsius_to_fahrenheit(20) == 68.0
    end
  end

  describe "volume conversions" do
    test "oz_to_ml/1" do
      assert NumberF.Metrics.oz_to_ml(1) == 29.57
      assert NumberF.Metrics.oz_to_ml(2) == 59.15
    end

    test "ml_to_oz/1" do
      assert NumberF.Metrics.ml_to_oz(29.57) == 1.0
      assert NumberF.Metrics.ml_to_oz(59.15) == 2.0
    end
  end

  describe "area conversions" do
    test "acres_to_hectares/1" do
      assert NumberF.Metrics.acres_to_hectares(2.47) == 1.0
      assert NumberF.Metrics.acres_to_hectares(1) == 0.4
    end

    test "hectares_to_acres/1" do
      assert NumberF.Metrics.hectares_to_acres(1) == 2.47
      assert NumberF.Metrics.hectares_to_acres(0.4) == 0.99
    end
  end

  describe "convert_units/4" do
    test "converts between metric units" do
      length_units = NumberF.Metrics.length_units()

      # Convert 5 cm to meters
      result = NumberF.Metrics.convert_units(5, "cm", "m", length_units)
      assert result == 0.05

      # Convert 1000 mm to meters
      result = NumberF.Metrics.convert_units(1000, "mm", "m", length_units)
      assert result == 1.0
    end

    test "raises error for unknown units" do
      length_units = NumberF.Metrics.length_units()

      assert_raise ArgumentError, fn ->
        NumberF.Metrics.convert_units(5, "unknown", "m", length_units)
      end
    end
  end
end
