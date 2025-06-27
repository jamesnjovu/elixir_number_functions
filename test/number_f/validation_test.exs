defmodule NumberF.ValidationTest do
  use ExUnit.Case
  doctest NumberF.Validation

  describe "is_valid_number?/1" do
    test "validates number strings" do
      assert NumberF.Validation.is_valid_number?("123") == true
      assert NumberF.Validation.is_valid_number?("123.45") == true
      assert NumberF.Validation.is_valid_number?("-123.45") == true
      assert NumberF.Validation.is_valid_number?("0") == true
    end

    test "rejects invalid number strings" do
      assert NumberF.Validation.is_valid_number?("abc") == false
      assert NumberF.Validation.is_valid_number?("123abc") == false
      assert NumberF.Validation.is_valid_number?("") == false
      assert NumberF.Validation.is_valid_number?(123) == false
    end
  end

  describe "is_valid_integer?/1" do
    test "validates integer strings" do
      assert NumberF.Validation.is_valid_integer?("123") == true
      assert NumberF.Validation.is_valid_integer?("-123") == true
      assert NumberF.Validation.is_valid_integer?("0") == true
    end

    test "rejects non-integer strings" do
      assert NumberF.Validation.is_valid_integer?("123.45") == false
      assert NumberF.Validation.is_valid_integer?("abc") == false
      assert NumberF.Validation.is_valid_integer?("") == false
      assert NumberF.Validation.is_valid_integer?(123) == false
    end
  end

  describe "is_valid_credit_card?/2" do
    test "validates credit card numbers using Luhn algorithm" do
      # Valid test credit card numbers
      assert NumberF.Validation.is_valid_credit_card?("4111111111111111") == true
      assert NumberF.Validation.is_valid_credit_card?("4111-1111-1111-1111") == true
      assert NumberF.Validation.is_valid_credit_card?("4111 1111 1111 1111") == true
    end

    test "rejects invalid credit card numbers" do
      assert NumberF.Validation.is_valid_credit_card?("4111111111111112") == false
      assert NumberF.Validation.is_valid_credit_card?("1234567890123456") == false
      assert NumberF.Validation.is_valid_credit_card?("abc") == false
    end

    test "validates specific card types" do
      assert NumberF.Validation.is_valid_credit_card?("4111111111111111", :visa) == true
      assert NumberF.Validation.is_valid_credit_card?("4111111111111111", :mastercard) == false
      assert NumberF.Validation.is_valid_credit_card?("378282246310005", :amex) == true
    end
  end
end
