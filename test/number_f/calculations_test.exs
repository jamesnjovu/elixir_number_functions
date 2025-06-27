defmodule NumberF.CalculationsTest do
  use ExUnit.Case
  # Import the custom assertions
  import CustomAssertions
  doctest NumberF.Calculations

  describe "percentage/3" do
    test "calculates percentage with default precision" do
      assert NumberF.Calculations.percentage(25, 100, 2) == 25.0
      assert NumberF.Calculations.percentage(33, 100, 2) == 33.0
      assert_float_equal(NumberF.Calculations.percentage(1, 3, 2), 33.33)
    end

    test "calculates percentage with custom precision" do
      assert NumberF.Calculations.percentage(1, 3, 0) == 33.0
      assert NumberF.Calculations.percentage(1, 3, 1) == 33.3
      assert NumberF.Calculations.percentage(1, 3, 4) == 33.3333
    end

    test "performance is acceptable" do
      test_data = TestHelper.financial_scenarios()

      # Should complete in < 1ms
      assert_performance(1000) do
        Enum.each(test_data, fn {principal, rate, _, _} ->
          NumberF.Calculations.percentage(principal * rate, principal, 2)
        end)
      end
    end
  end

  describe "round_to_nearest/2" do
    test "rounds to nearest integer by default" do
      assert NumberF.Calculations.round_to_nearest(12.3, 1.0) == 12.0
      assert NumberF.Calculations.round_to_nearest(12.5, 1.0) == 13.0
      assert NumberF.Calculations.round_to_nearest(12.7, 1.0) == 13.0
    end

    test "rounds to custom nearest value" do
      assert NumberF.Calculations.round_to_nearest(12.3, 5) == 10.0
      assert NumberF.Calculations.round_to_nearest(12.5, 5) == 15.0
      assert NumberF.Calculations.round_to_nearest(12.3, 0.5) == 12.5
    end
  end

  describe "in_range?/3" do
    test "checks if value is within range" do
      assert NumberF.Calculations.in_range?(5, 1, 10) == true
      assert NumberF.Calculations.in_range?(1, 1, 10) == true
      assert NumberF.Calculations.in_range?(10, 1, 10) == true
      assert NumberF.Calculations.in_range?(0, 1, 10) == false
      assert NumberF.Calculations.in_range?(11, 1, 10) == false
    end
  end

  describe "interpolate/5" do
    test "performs linear interpolation" do
      assert NumberF.Calculations.interpolate(2.5, 2, 10, 3, 20) == 15.0
      assert NumberF.Calculations.interpolate(1, 0, 0, 2, 10) == 5.0
      assert NumberF.Calculations.interpolate(0.5, 0, 0, 1, 100) == 50.0
    end
  end

  describe "gcd/2" do
    test "calculates greatest common divisor" do
      assert NumberF.Calculations.gcd(48, 18) == 6
      assert NumberF.Calculations.gcd(7, 13) == 1
      assert NumberF.Calculations.gcd(0, 5) == 5
      assert NumberF.Calculations.gcd(12, 0) == 12
    end
  end

  describe "lcm/2" do
    test "calculates least common multiple" do
      assert NumberF.Calculations.lcm(4, 6) == 12
      assert NumberF.Calculations.lcm(21, 6) == 42
      assert NumberF.Calculations.lcm(0, 0) == 0
    end
  end

  describe "is_prime?/1" do
    test "checks if number is prime" do
      assert NumberF.Calculations.is_prime?(2) == true
      assert NumberF.Calculations.is_prime?(3) == true
      assert NumberF.Calculations.is_prime?(7) == true
      assert NumberF.Calculations.is_prime?(11) == true
      assert NumberF.Calculations.is_prime?(4) == false
      assert NumberF.Calculations.is_prime?(6) == false
      assert NumberF.Calculations.is_prime?(1) == false
      assert NumberF.Calculations.is_prime?(0) == false
    end
  end

  describe "factorial/1" do
    test "calculates factorial" do
      assert NumberF.Calculations.factorial(0) == 1
      assert NumberF.Calculations.factorial(1) == 1
      assert NumberF.Calculations.factorial(5) == 120
      assert NumberF.Calculations.factorial(7) == 5040
    end
  end

  describe "combinations/2" do
    test "calculates combinations" do
      assert NumberF.Calculations.combinations(5, 2) == 10.0
      assert NumberF.Calculations.combinations(10, 3) == 120.0
      assert NumberF.Calculations.combinations(4, 0) == 1.0
    end
  end

  describe "to_radians/1" do
    test "converts degrees to radians" do
      assert NumberF.Calculations.to_radians(180) == :math.pi()
      assert NumberF.Calculations.to_radians(90) == :math.pi() / 2
      assert NumberF.Calculations.to_radians(0) == 0
    end
  end

  describe "to_degrees/1" do
    test "converts radians to degrees" do
      assert NumberF.Calculations.to_degrees(:math.pi()) == 180.0
      assert NumberF.Calculations.to_degrees(:math.pi() / 2) == 90.0
      assert NumberF.Calculations.to_degrees(0) == 0.0
    end
  end
end
