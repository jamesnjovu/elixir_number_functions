
defmodule NumberFTest do
  use ExUnit.Case
  doctest NumberF

  describe "currency formatting" do
    test "formats numbers with default currency (ZMW)" do
      assert NumberF.currency(1234.567) == "ZMW 1,234.57"
      assert NumberF.currency(1234) == "ZMW 1,234.00"
      assert NumberF.currency(0) == "ZMW 0.00"
    end

    test "formats numbers with custom currency" do
      assert NumberF.currency(1234.567, "USD") == "USD 1,234.57"
      assert NumberF.currency(1234.567, "EUR") == "EUR 1,234.57"
      assert NumberF.currency(1234.567, "£", 2) == "£ 1,234.57"
    end

    test "formats numbers with custom precision" do
      assert NumberF.currency(1234.567, "USD", 0) == "USD 1,235"
      assert NumberF.currency(1234.567, "USD", 1) == "USD 1,234.6"
      assert NumberF.currency(1234.567, "USD", 3) == "USD 1,234.567"
    end

    test "returns nil when input is nil" do
      assert NumberF.currency(nil) == nil
    end
  end

  describe "comma_separated formatting" do
    test "formats numbers with default precision" do
      assert NumberF.comma_separated(1234567.89) == "1,234,567.89"
      assert NumberF.comma_separated(1234) == "1,234.00"
      assert NumberF.comma_separated(0) == "0.00"
    end

    test "formats numbers with custom precision" do
      assert NumberF.comma_separated(1234567.89, 0) == "1,234,568"
      assert NumberF.comma_separated(1234567.89, 1) == "1,234,567.9"
      assert NumberF.comma_separated(1234567.89, 3) == "1,234,567.890"
    end

    test "returns nil when input is nil" do
      assert NumberF.comma_separated(nil) == nil
    end
  end

  describe "numbers to words conversion" do
    test "converts integers" do
      assert NumberF.to_words(0) == "zero Kwacha"
      assert NumberF.to_words(1) == "One Kwacha"
      assert NumberF.to_words(21) == "Twenty One Kwacha"
      assert NumberF.to_words(100) == "One Hundred Kwacha"
      assert NumberF.to_words(123) == "One Hundred Twenty Three Kwacha"
      assert NumberF.to_words(1234) == "One Thousand Two Hundred Thirty Four Kwacha"
    end

    test "converts floats" do
      assert NumberF.to_words(1.5) == "One Kwacha And Fifty Ngwee"
      assert NumberF.to_words(21.42) == "Twenty One Kwacha And Forty Two Ngwee"
    end

    test "uses custom currency terms" do
      assert NumberF.to_words(1, "Dollar", "Cent") == "One Dollar"
      assert NumberF.to_words(1.5, "Dollar", "Cent") == "One Dollar And Fifty Cent"
      assert NumberF.to_words(0, "Euro", "Cent") == "zero Euro"
    end
  end

  describe "memory size calculation" do
    test "handles bytes" do
      assert NumberF.memory_size_cal(500) == "500 B"
      assert NumberF.memory_size_cal(1023) == "1023 B"
    end

    test "handles kilobytes" do
      assert NumberF.memory_size_cal(1024) == "1.0 KB"
      assert NumberF.memory_size_cal(1536) == "1.5 KB"
      assert NumberF.memory_size_cal(10240) == "10.0 KB"
    end

    test "handles megabytes" do
      assert NumberF.memory_size_cal(1_048_576) == "1.0 MB"
      assert NumberF.memory_size_cal(2_097_152) == "2.0 MB"
    end

    test "handles gigabytes" do
      assert NumberF.memory_size_cal(1_073_741_824) == "1.0 GB"
      assert NumberF.memory_size_cal(2_147_483_648) == "2.0 GB"
    end
  end

  describe "randomizer" do
    test "generates string of specified length" do
      result = NumberF.randomizer(10)
      assert String.length(result) == 10
      # Check it's alphanumeric (a-zA-Z0-9)
      assert String.match?(result, ~r/^[a-zA-Z0-9]+$/)
    end

    test "generates numeric string" do
      result = NumberF.randomizer(8, :numeric)
      assert String.length(result) == 8
      # Check it contains only digits
      assert String.match?(result, ~r/^[0-9]+$/)
    end

    test "generates uppercase string" do
      result = NumberF.randomizer(6, :upcase)
      assert String.length(result) == 6
      # Check it contains only uppercase letters
      assert String.match?(result, ~r/^[A-Z]+$/)
    end

    test "generates lowercase string" do
      result = NumberF.randomizer(7, :downcase)
      assert String.length(result) == 7
      # Check it contains only lowercase letters
      assert String.match?(result, ~r/^[a-z]+$/)
    end

    test "generates alphabetic string" do
      result = NumberF.randomizer(9, :alpha)
      assert String.length(result) == 9
      # Check it contains letters (and possibly numbers)
      assert String.match?(result, ~r/^[a-zA-Z0-9]+$/)
    end
  end

  describe "default_password" do
    test "follows expected format" do
      result = NumberF.default_password()
      # Should be a capitalized 3-letter string + @ + 4 digits
      assert String.match?(result, ~r/^[A-Z][a-z]{2}@[0-9]{4}$/)
      assert String.length(result) == 8
    end
  end

  describe "type conversion" do
    test "to_int" do
      assert NumberF.to_int("123") == 123
      assert NumberF.to_int("123.45") == 123
    end

    test "to_float" do
      assert NumberF.to_float("123.45") == 123.45
      assert NumberF.to_float(123) == 123.0
    end

    test "to_decimal" do
      decimal = NumberF.to_decimal("123.45")
      assert Decimal.equal?(decimal, Decimal.new("123.45"))

      decimal = NumberF.to_decimal(123)
      assert Decimal.equal?(decimal, Decimal.new(123))
    end

    test "to_boolean" do
      assert NumberF.to_boolean("true") == true
      assert NumberF.to_boolean("yes") == true
      assert NumberF.to_boolean("on") == true

      assert NumberF.to_boolean("false") == false
      assert NumberF.to_boolean("no") == false
      assert NumberF.to_boolean("off") == false

      assert_raise ArgumentError, fn -> NumberF.to_boolean("invalid") end
    end
  end

  describe "number_to_delimited" do
    test "with default options" do
      assert NumberF.number_to_delimited(1234567.89) == "1,234,567.89"
      assert NumberF.number_to_delimited(1234) == "1,234.00"
    end

    test "with custom delimiter and separator" do
      assert NumberF.number_to_delimited(1234567.89, delimiter: ".", separator: ",") == "1.234.567,89"
      assert NumberF.number_to_delimited(1234567.89, delimiter: " ", separator: ".") == "1 234 567.89"
    end

    test "with custom precision" do
      assert NumberF.number_to_delimited(1234567.89, precision: 0) == "1,234,568"
      assert NumberF.number_to_delimited(1234567.89, precision: 3) == "1,234,567.890"
    end
  end

  describe "percentage calculation" do
    test "calculates percentage with default precision" do
      assert NumberF.percentage(25, 100) == 25.0
      assert NumberF.percentage(33, 100) == 33.0
      assert NumberF.percentage(1, 3) == 33.33
    end

    test "calculates percentage with custom precision" do
      assert NumberF.percentage(1, 3, 0) == 33.0
      assert NumberF.percentage(1, 3, 1) == 33.3
      assert NumberF.percentage(1, 3, 3) == 33.333
    end
  end

  describe "round_to_nearest" do
    test "rounds to nearest integer by default" do
      assert NumberF.round_to_nearest(12.3) == 12.0
      assert NumberF.round_to_nearest(12.5) == 13.0
      assert NumberF.round_to_nearest(12.7) == 13.0
    end

    test "rounds to custom nearest value" do
      assert NumberF.round_to_nearest(12.3, 5) == 10.0
      assert NumberF.round_to_nearest(12.5, 5) == 15.0
      assert NumberF.round_to_nearest(12.3, 0.5) == 12.5
      assert NumberF.round_to_nearest(12.1, 0.5) == 12.0
    end
  end

  describe "in_range?" do
    test "checks if value is within range" do
      assert NumberF.in_range?(5, 1, 10) == true
      assert NumberF.in_range?(1, 1, 10) == true
      assert NumberF.in_range?(10, 1, 10) == true
      assert NumberF.in_range?(0, 1, 10) == false
      assert NumberF.in_range?(11, 1, 10) == false
    end
  end

  describe "financial functions" do
    test "simple_interest" do
      assert NumberF.simple_interest(1000, 0.05, 2) == 100.0
      assert NumberF.simple_interest(5000, 0.03, 1) == 150.0
    end

    test "compound_interest" do
      assert NumberF.compound_interest(1000, 0.05, 2) == 102.5
      # With monthly compounding
      assert NumberF.compound_interest(1000, 0.05, 2, 12) == 104.94
    end

    test "calculate_emi" do
      assert NumberF.calculate_emi(100000, 0.10, 12) == 8791.59
    end

    test "convert_currency" do
      assert NumberF.convert_currency(100, 1, 1.1) == 110.0
      assert NumberF.convert_currency(100, 1.1, 1) == 90.9090909090909
    end
  end

  describe "statistical functions" do
    test "mean" do
      assert NumberF.mean([1, 2, 3, 4, 5]) == 3.0
      assert NumberF.mean([]) == nil
    end

    test "median" do
      assert NumberF.median([1, 3, 5, 7, 9]) == 5
      assert NumberF.median([1, 3, 5, 7]) == 4.0
      assert NumberF.median([]) == nil
    end

    test "mode" do
      assert NumberF.mode([1, 2, 2, 3, 3, 3, 4]) == [3]
      assert NumberF.mode([1, 1, 2, 2, 3]) == [1, 2]
      assert NumberF.mode([]) == []
    end

    test "standard_deviation" do
      assert NumberF.standard_deviation([2, 4, 4, 4, 5, 5, 7, 9]) == 2.0
      assert NumberF.standard_deviation([1]) == 0.0
      assert NumberF.standard_deviation([]) == nil
    end
  end

  describe "number validation" do
    test "is_valid_number?" do
      assert NumberF.is_valid_number?("123") == true
      assert NumberF.is_valid_number?("123.45") == true
      assert NumberF.is_valid_number?("abc") == false
      assert NumberF.is_valid_number?(123) == false
    end

    test "is_valid_integer?" do
      assert NumberF.is_valid_integer?("123") == true
      assert NumberF.is_valid_integer?("123.45") == false
      assert NumberF.is_valid_integer?("abc") == false
      assert NumberF.is_valid_integer?(123) == false
    end

    test "is_valid_credit_card?" do
      # Test with a valid Visa card number (test number, not real)
      assert NumberF.is_valid_credit_card?("4111111111111111") == true
      # Test with an invalid card number
      assert NumberF.is_valid_credit_card?("4111111111111112") == false
      # Test with specified card type
      assert NumberF.is_valid_credit_card?("4111111111111111", :visa) == true
      assert NumberF.is_valid_credit_card?("4111111111111111", :mastercard) == false
    end
  end

  describe "phone formatting" do
    test "format_phone with default country code (ZM)" do
      assert NumberF.format_phone("260977123456") == "+260 97 712 3456"
      assert NumberF.format_phone("0977123456") == "097 712 3456"
    end

    test "format_phone with US country code" do
      assert NumberF.format_phone("14155552671", "US") == "+1 (415) 555-2671"
      assert NumberF.format_phone("4155552671", "US") == "(415) 555-2671"
    end

    test "format_phone with UK country code" do
      assert NumberF.format_phone("447911123456", "UK") == "+44 79 1112 3456"
      assert NumberF.format_phone("07911123456", "UK") == "079 1112 3456"
    end
  end

  describe "number abbreviation" do
    test "abbreviate_number with default precision" do
      assert NumberF.abbreviate_number(123) == "123"
      assert NumberF.abbreviate_number(1234) == "1.2K"
      assert NumberF.abbreviate_number(1234567) == "1.2M"
      assert NumberF.abbreviate_number(1234567890) == "1.2B"
    end

    test "abbreviate_number with custom precision" do
      assert NumberF.abbreviate_number(1234, 2) == "1.23K"
      assert NumberF.abbreviate_number(1234567, 3) == "1.235M"
    end
  end

  describe "ordinal numbers" do
    test "ordinal" do
      assert NumberF.ordinal(1) == "1st"
      assert NumberF.ordinal(2) == "2nd"
      assert NumberF.ordinal(3) == "3rd"
      assert NumberF.ordinal(4) == "4th"
      assert NumberF.ordinal(11) == "11th"
      assert NumberF.ordinal(21) == "21st"
      assert NumberF.ordinal(102) == "102nd"
      assert NumberF.ordinal(113) == "113th"
    end
  end

  describe "roman numerals" do
    test "to_roman" do
      assert NumberF.to_roman(1) == "I"
      assert NumberF.to_roman(4) == "IV"
      assert NumberF.to_roman(9) == "IX"
      assert NumberF.to_roman(42) == "XLII"
      assert NumberF.to_roman(99) == "XCIX"
      assert NumberF.to_roman(1999) == "MCMXCIX"
    end

    test "from_roman" do
      assert NumberF.from_roman("I") == 1
      assert NumberF.from_roman("IV") == 4
      assert NumberF.from_roman("IX") == 9
      assert NumberF.from_roman("XLII") == 42
      assert NumberF.from_roman("XCIX") == 99
      assert NumberF.from_roman("MCMXCIX") == 1999
    end
  end

  describe "date calculations" do
    test "calculate_age" do
      today = Date.utc_today()
      twenty_years_ago = %{today | year: today.year - 20}
      assert NumberF.calculate_age(twenty_years_ago) == 20
    end

    test "payment_due_date with default terms" do
      invoice_date = ~D[2023-01-15]
      assert NumberF.payment_due_date(invoice_date) == ~D[2023-02-14]
    end

    test "payment_due_date with custom terms" do
      invoice_date = ~D[2023-01-15]
      assert NumberF.payment_due_date(invoice_date, 45) == ~D[2023-03-01]
    end
  end
end
