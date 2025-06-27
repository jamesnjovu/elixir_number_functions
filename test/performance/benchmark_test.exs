defmodule NumberF.BenchmarkTest do
  use ExUnit.Case

  describe "benchmark tests" do
    @describetag :benchmark
    test "currency formatting benchmark" do
      amounts = TestHelper.random_numbers(1000)

      {time_microseconds, _} =
        :timer.tc(fn ->
          Enum.each(amounts, fn amount ->
            NumberF.currency(amount, "USD", 2)
          end)
        end)

      time_per_operation = time_microseconds / 1000
      IO.puts("Currency formatting: #{time_per_operation} μs per operation")

      # Should be fast (less than 50 μs per operation)
      assert time_per_operation < 50
    end

    test "statistical calculations benchmark" do
      large_dataset = TestHelper.random_numbers(10000)

      {time_microseconds, _} =
        :timer.tc(fn ->
          NumberF.mean(large_dataset)
          NumberF.median(large_dataset)
          NumberF.standard_deviation(large_dataset)
        end)

      IO.puts("Statistical calculations (10k items): #{time_microseconds / 1000} ms")

      # Should complete within reasonable time (less than 100ms)
      assert time_microseconds < 100_000
    end

    test "number to words benchmark" do
      numbers = [1, 123, 1234, 12345, 123_456, 1_234_567, 12_345_678, 123_456_789]

      {time_microseconds, _} =
        :timer.tc(fn ->
          Enum.each(numbers, fn number ->
            NumberF.to_words(number, "Dollar", "Cent")
          end)
        end)

      time_per_conversion = time_microseconds / length(numbers)
      IO.puts("Number to words: #{time_per_conversion} μs per conversion")

      # Should be reasonably fast (less than 1000 μs per conversion)
      assert time_per_conversion < 1000
    end
  end
end
