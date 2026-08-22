defmodule NumberF.HelperTest do
  use ExUnit.Case
  doctest NumberF.Helper

  describe "int_pow10/2" do
    test "calculates powers of 10" do
      assert NumberF.Helper.int_pow10(1, 0) == 1
      assert NumberF.Helper.int_pow10(1, 1) == 10
      assert NumberF.Helper.int_pow10(1, 2) == 100
      assert NumberF.Helper.int_pow10(1, 3) == 1000
      assert NumberF.Helper.int_pow10(2, 2) == 200
      assert NumberF.Helper.int_pow10(5, 3) == 5000
    end

    test "handles large powers" do
      assert NumberF.Helper.int_pow10(1, 10) == 10_000_000_000
    end
  end
end
