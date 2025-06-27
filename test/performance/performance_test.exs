defmodule NumberFPerformanceTest do
  use ExUnit.Case

  @tag :performance
  describe "performance tests" do
    test "currency formatting performance" do
      numbers = Enum.to_list(1..1000)

      {time, _result} =
        :timer.tc(fn ->
          Enum.each(numbers, fn n ->
            NumberF.currency(n * 1.23, "USD", 2)
          end)
        end)

      # Should complete in reasonable time (less than 100ms for 1000 operations)
      assert time < 100_000
    end

    test "statistical calculations performance" do
      large_dataset = Enum.to_list(1..10000)

      {time, _result} =
        :timer.tc(fn ->
          NumberF.mean(large_dataset)
          NumberF.median(large_dataset)
          NumberF.standard_deviation(large_dataset)
        end)

      # Should complete in reasonable time
      assert time < 500_000
    end

    test "number to words performance" do
      numbers = [1, 123, 1234, 12345, 123_456, 1_234_567]

      {time, _result} =
        :timer.tc(fn ->
          Enum.each(numbers, fn n ->
            NumberF.to_words(n, "Dollar", "Cent")
          end)
        end)

      # Should complete quickly
      assert time < 50_000
    end
  end
end
