defmodule NumberF.Helper do
  def int_pow10(num, 0), do: num
  def int_pow10(num, pow) when pow > 0, do: int_pow10(10 * num, pow - 1)
end

defmodule NumberF.NumbersToWords do
  alias NumberF.Helper, as: Math

  def parse(0, main_c, _), do: "zero #{main_c}"

  def parse(number, main_c, _) when is_integer(number) do
    words =
      to_word(number)
      |> List.flatten()
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    words <> " #{main_c}"
  end

  def parse(number, main_c, sec_c) when is_float(number) do
    [whole, floating] =
      Decimal.from_float(number) |> Decimal.round(2) |> Decimal.to_string() |> String.split(".")

    whole = String.to_integer(whole)
    floating = String.to_integer(floating)
    if floating == 0 do
      parse(whole, main_c, sec_c)
    else
      amount =
        to_word(whole)
        |> List.flatten()
        |> Enum.filter(& &1)
        |> Enum.join(" ")

      trailing =
        if(floating > 0) do
          floating =
            to_word(floating)
            |> List.flatten()
            |> Enum.filter(& &1)
            |> Enum.join(" ")

          " #{main_c} And " <> floating <> " #{sec_c}"
        else
          " "
        end

      amount <> trailing
    end
  end

  def parse(unknown, _, _), do: raise(ArgumentError, message: "#{unknown} is not an integer")

  defp to_word(0), do: [nil]
  defp to_word(1), do: ["One"]
  defp to_word(2), do: ["Two"]
  defp to_word(3), do: ["Three"]
  defp to_word(4), do: ["Four"]
  defp to_word(5), do: ["Five"]
  defp to_word(6), do: ["Six"]
  defp to_word(7), do: ["Seven"]
  defp to_word(8), do: ["Eight"]
  defp to_word(9), do: ["Nine"]
  defp to_word(10), do: ["Ten"]
  defp to_word(11), do: ["Eleven"]
  defp to_word(12), do: ["Twelve"]
  defp to_word(13), do: ["Thirteen"]
  defp to_word(14), do: ["Fourteen"]
  defp to_word(15), do: ["Fifteen"]
  defp to_word(16), do: ["Sixteen"]
  defp to_word(17), do: ["Seventeen"]
  defp to_word(18), do: ["Eighteen"]
  defp to_word(19), do: ["Nineteen"]
  defp to_word(20), do: ["Twenty"]
  defp to_word(30), do: ["Thirty"]
  defp to_word(40), do: ["Forty"]
  defp to_word(50), do: ["Fifty"]
  defp to_word(60), do: ["Sixty"]
  defp to_word(70), do: ["Seventy"]
  defp to_word(80), do: ["Eighty"]
  defp to_word(90), do: ["Ninety"]
  defp to_word(n) when n < 0, do: ["negative", to_word(-n)]
  defp to_word(n) when n < 100, do: [to_word(div(n, 10) * 10), to_word(rem(n, 10))]
  defp to_word(n) when n < 1_000, do: [to_word(div(n, 100)), "Hundred", to_word(rem(n, 100))]

  ~w[ Thousand Million Billion Trillion Quadrillion Quintillion Sextillion Septillion Octillion Nonillion Decillion ]
  |> Enum.zip(2..13)
  |> Enum.each(fn {illion, factor} ->
    defp to_word(n) when n < unquote(Math.int_pow10(1, factor * 3)) do
      [
        to_word(div(n, unquote(Math.int_pow10(1, (factor - 1) * 3)))),
        unquote(illion),
        to_word(rem(n, unquote(Math.int_pow10(1, (factor - 1) * 3))))
      ]
    end
  end)

  def try() do
    Decimal.new("2.5")
    |> Decimal.to_float()
    |> parse("Kwacha", "Ngwee")
  end

  defp to_word(_), do: raise(ArgumentError, message: "number is too long")
end

defmodule NumberF.NumberToWord do
  @spec say(integer) :: String.t()
  def say(n), do: n |> say_io() |> IO.iodata_to_binary()

  @spec say_io(integer) :: iodata
  def say_io(1), do: "One"
  def say_io(2), do: "Two"
  def say_io(3), do: "Three"
  def say_io(4), do: "Four"
  def say_io(5), do: "Five"
  def say_io(6), do: "Six"
  def say_io(7), do: "Seven"
  def say_io(8), do: "Eight"
  def say_io(9), do: "Nine"
  def say_io(10), do: "Ten"
  def say_io(11), do: "Eleven"
  def say_io(12), do: "Twelve"
  def say_io(13), do: "Thirteen"
  def say_io(14), do: "Fourteen"
  def say_io(15), do: "Fifteen"
  def say_io(16), do: "Sixteen"
  def say_io(17), do: "Seventeen"
  def say_io(18), do: "Eighteen"
  def say_io(19), do: "Nineteen"
  def say_io(20), do: "Twenty"
  def say_io(30), do: "Thirty"
  def say_io(40), do: "Forty"
  def say_io(50), do: "Fifty"
  def say_io(60), do: "Sixty"
  def say_io(70), do: "Seventy"
  def say_io(80), do: "Eighty"
  def say_io(90), do: "Ninety"

  def say_io(n) when n < 100 do
    tens = div(n, 10) * 10
    remainder = rem(n, 10)
    format(tens, "", " ", remainder)
  end

  def say_io(n) when n < 1000 do
    hundreds = div(n, 100)
    remainder = rem(n, 100)
    format(hundreds, " Hundred", separator(remainder), remainder)
  end

  ~w[thousand million billion trillion quadrillion quintillion sextillion septillion octillion nonillion decillion]
  |> Enum.zip(Stream.unfold(1000, fn acc -> {acc, acc * 1000} end))
  |> Enum.each(fn {suffix, m} ->
    def say_io(n) when n < unquote(m) * 1000 do
      number = div(n, unquote(m))
      remainder = rem(n, unquote(m))
      format(number, " " <> unquote(suffix), separator(remainder), remainder)
    end
  end)

  @spec separator(integer) :: String.t()
  def separator(remainder) when remainder < 100, do: " and "
  def separator(_remainder), do: ", "

  @spec format(integer, String.t(), String.t(), integer) :: iodata
  def format(number, illion, _separator, 0), do: [say_io(number) | illion]

  def format(number, illion, separator, remainder),
    do: [say_io(number), illion, separator | say_io(remainder)]
end
