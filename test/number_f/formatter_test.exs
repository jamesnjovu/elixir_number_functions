defmodule NumberF.FormatterTest do
  use ExUnit.Case
  doctest NumberF.Formatter

  describe "format_phone/2" do
    test "formats Zambian phone numbers" do
      assert NumberF.Formatter.format_phone("260977123456", "ZM") == "+260 97 712 3456"
      assert NumberF.Formatter.format_phone("0977123456", "ZM") == "097 712 3456"
    end

    test "formats US phone numbers" do
      assert NumberF.Formatter.format_phone("14155552671", "US") == "+1 (415) 555-2671"
      assert NumberF.Formatter.format_phone("4155552671", "US") == "(415) 555-2671"
    end

    test "formats UK phone numbers" do
      assert NumberF.Formatter.format_phone("447911123456", "UK") == "+44 79 1112 3456"
      assert NumberF.Formatter.format_phone("07911123456", "UK") == "079 1112 3456"
    end

    test "handles generic international format" do
      assert NumberF.Formatter.format_phone("1234567890", "XX") == "+1234567890"
    end
  end

  describe "abbreviate_number/2" do
    test "abbreviates numbers correctly" do
      assert NumberF.Formatter.abbreviate_number(123, 1) == "123"
      assert NumberF.Formatter.abbreviate_number(1234, 1) == "1.2K"
      assert NumberF.Formatter.abbreviate_number(1_234_567, 1) == "1.2M"
      assert NumberF.Formatter.abbreviate_number(1_234_567_890, 1) == "1.2B"
    end

    test "uses custom precision" do
      assert NumberF.Formatter.abbreviate_number(1234, 2) == "1.23K"
      assert NumberF.Formatter.abbreviate_number(1_234_567, 3) == "1.235M"
    end
  end

  describe "ordinal/1" do
    test "creates ordinal numbers" do
      assert NumberF.Formatter.ordinal(1) == "1st"
      assert NumberF.Formatter.ordinal(2) == "2nd"
      assert NumberF.Formatter.ordinal(3) == "3rd"
      assert NumberF.Formatter.ordinal(4) == "4th"
      assert NumberF.Formatter.ordinal(11) == "11th"
      assert NumberF.Formatter.ordinal(21) == "21st"
      assert NumberF.Formatter.ordinal(102) == "102nd"
      assert NumberF.Formatter.ordinal(113) == "113th"
    end
  end

  describe "to_roman/1" do
    test "converts to roman numerals" do
      assert NumberF.Formatter.to_roman(1) == "I"
      assert NumberF.Formatter.to_roman(4) == "IV"
      assert NumberF.Formatter.to_roman(9) == "IX"
      assert NumberF.Formatter.to_roman(42) == "XLII"
      assert NumberF.Formatter.to_roman(99) == "XCIX"
      assert NumberF.Formatter.to_roman(1999) == "MCMXCIX"
    end
  end

  describe "from_roman/1" do
    test "converts from roman numerals" do
      assert NumberF.Formatter.from_roman("I") == 1
      assert NumberF.Formatter.from_roman("IV") == 4
      assert NumberF.Formatter.from_roman("IX") == 9
      assert NumberF.Formatter.from_roman("XLII") == 42
      assert NumberF.Formatter.from_roman("XCIX") == 99
      assert NumberF.Formatter.from_roman("MCMXCIX") == 1999
    end
  end
end
