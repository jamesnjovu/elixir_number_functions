defmodule NumberF.NumbersToWordsTest do
  use ExUnit.Case
  doctest NumberF.NumbersToWords

  describe "parse/3" do
    test "converts zero correctly" do
      assert NumberF.NumbersToWords.parse(0, "Kwacha", "Ngwee") == "zero Kwacha"
      assert NumberF.NumbersToWords.parse(0, "Dollar", "Cent") == "zero Dollar"
    end

    test "converts integers correctly" do
      assert NumberF.NumbersToWords.parse(1, "Kwacha", "Ngwee") == "One Kwacha"
      assert NumberF.NumbersToWords.parse(21, "Kwacha", "Ngwee") == "Twenty One Kwacha"
      assert NumberF.NumbersToWords.parse(100, "Kwacha", "Ngwee") == "One Hundred Kwacha"

      assert NumberF.NumbersToWords.parse(123, "Kwacha", "Ngwee") ==
               "One Hundred Twenty Three Kwacha"

      assert NumberF.NumbersToWords.parse(1234, "Kwacha", "Ngwee") ==
               "One Thousand Two Hundred Thirty Four Kwacha"
    end

    test "converts floats correctly" do
      assert NumberF.NumbersToWords.parse(1.5, "Kwacha", "Ngwee") == "One Kwacha And Fifty Ngwee"

      assert NumberF.NumbersToWords.parse(21.42, "Kwacha", "Ngwee") ==
               "Twenty One Kwacha And Forty Two Ngwee"

      assert NumberF.NumbersToWords.parse(100.01, "Dollar", "Cent") ==
               "One Hundred Dollar And One Cent"
    end

    test "handles zero cents correctly" do
      assert NumberF.NumbersToWords.parse(20.0, "Kwacha", "Ngwee") == "Twenty Kwacha"
      assert NumberF.NumbersToWords.parse(100.00, "Dollar", "Cent") == "One Hundred Dollar"
    end

    test "uses custom currency terms" do
      assert NumberF.NumbersToWords.parse(1, "Euro", "Cent") == "One Euro"
      assert NumberF.NumbersToWords.parse(1.5, "Pound", "Pence") == "One Pound And Fifty Pence"
    end

    test "handles large numbers" do
      assert NumberF.NumbersToWords.parse(1_000_000, "Dollar", "Cent") == "One Million Dollar"

      assert NumberF.NumbersToWords.parse(1_234_567, "Dollar", "Cent") ==
               "One Million Two Hundred Thirty Four Thousand Five Hundred Sixty Seven Dollar"
    end

    test "raises error for non-numeric input" do
      assert_raise ArgumentError, fn ->
        NumberF.NumbersToWords.parse("invalid", "Dollar", "Cent")
      end
    end
  end
end
