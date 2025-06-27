defmodule NumberF.RandomizerTest do
  use ExUnit.Case
  doctest NumberF.Randomizer

  describe "randomizer/2" do
    test "generates string of correct length" do
      result = NumberF.Randomizer.randomizer(10, :all)
      assert String.length(result) == 10
    end

    test "generates numeric strings" do
      result = NumberF.Randomizer.randomizer(8, :numeric)
      assert String.length(result) == 8
      assert String.match?(result, ~r/^[0-9]+$/)
    end

    test "generates uppercase strings" do
      result = NumberF.Randomizer.randomizer(6, :upcase)
      assert String.length(result) == 6
      assert String.match?(result, ~r/^[A-Z]+$/)
    end

    test "generates lowercase strings" do
      result = NumberF.Randomizer.randomizer(7, :downcase)
      assert String.length(result) == 7
      assert String.match?(result, ~r/^[a-z]+$/)
    end

    test "generates alpha strings" do
      result = NumberF.Randomizer.randomizer(9, :alpha)
      assert String.length(result) == 9
      # Should contain letters and possibly numbers
      assert String.match?(result, ~r/^[a-zA-Z0-9]+$/)
    end
  end

  describe "gen_password/0" do
    test "generates password in correct format" do
      result = NumberF.Randomizer.gen_password()
      assert String.length(result) == 8
      # Should match pattern: Abc@1234
      assert String.match?(result, ~r/^[A-Z][a-z]{2}@[0-9]{4}$/)
    end
  end
end
