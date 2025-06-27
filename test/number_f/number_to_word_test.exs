defmodule NumberF.NumberToWordTest do
  use ExUnit.Case
  doctest NumberF.NumberToWord

  describe "say/1" do
    test "converts basic numbers" do
      assert NumberF.NumberToWord.say(1) == "One"
      assert NumberF.NumberToWord.say(5) == "Five"
      assert NumberF.NumberToWord.say(10) == "Ten"
      assert NumberF.NumberToWord.say(15) == "Fifteen"
      assert NumberF.NumberToWord.say(20) == "Twenty"
    end

    test "converts tens" do
      assert NumberF.NumberToWord.say(21) == "Twenty One"
      assert NumberF.NumberToWord.say(35) == "Thirty Five"
      assert NumberF.NumberToWord.say(99) == "Ninety Nine"
    end

    test "converts hundreds" do
      assert NumberF.NumberToWord.say(100) == "One Hundred"
      assert NumberF.NumberToWord.say(101) == "One Hundred and One"
      assert NumberF.NumberToWord.say(123) == "One Hundred and Twenty Three"
      assert NumberF.NumberToWord.say(999) == "Nine Hundred and Ninety Nine"
    end

    test "converts thousands" do
      assert NumberF.NumberToWord.say(1000) == "One thousand"
      assert NumberF.NumberToWord.say(1001) == "One thousand and One"
      assert NumberF.NumberToWord.say(1100) == "One thousand, One Hundred"
      assert NumberF.NumberToWord.say(1234) == "One thousand, Two Hundred and Thirty Four"
    end

    test "converts millions" do
      assert NumberF.NumberToWord.say(1_000_000) == "One million"
      assert NumberF.NumberToWord.say(1_000_001) == "One million and One"

      assert NumberF.NumberToWord.say(1_234_567) ==
               "One million, Two Hundred and Thirty Four thousand, Five Hundred and Sixty Seven"
    end

    test "converts billions" do
      assert NumberF.NumberToWord.say(1_000_000_000) == "One billion"
      assert NumberF.NumberToWord.say(1_000_000_001) == "One billion and One"
    end
  end

  describe "say_io/1" do
    test "returns iodata for basic numbers" do
      assert NumberF.NumberToWord.say_io(1) == "One"
      assert NumberF.NumberToWord.say_io(21) == ["Twenty", "", " ", "One"]
    end
  end

  describe "separator/1" do
    test "returns correct separator" do
      assert NumberF.NumberToWord.separator(50) == " and "
      assert NumberF.NumberToWord.separator(150) == ", "
    end
  end
end
