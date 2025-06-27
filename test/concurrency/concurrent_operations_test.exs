defmodule NumberF.ConcurrencyTest do
  use ExUnit.Case

  @tag :concurrency
  describe "concurrent operations" do
    test "currency formatting is thread-safe" do
      # Spawn multiple processes doing currency formatting
      tasks =
        Enum.map(1..100, fn i ->
          Task.async(fn ->
            amount = i * 123.45
            NumberF.currency(amount, "USD", 2)
          end)
        end)

      # Wait for all tasks to complete
      results = Enum.map(tasks, &Task.await/1)

      # All should complete successfully
      assert length(results) == 100

      Enum.each(results, fn result ->
        assert is_binary(result)
        assert String.contains?(result, "USD")
      end)
    end

    test "statistical calculations are thread-safe" do
      # Generate test data
      test_data = Enum.to_list(1..1000)

      # Run statistical calculations concurrently
      tasks =
        Enum.map(1..50, fn _ ->
          Task.async(fn ->
            %{
              mean: NumberF.mean(test_data),
              median: NumberF.median(test_data),
              std_dev: NumberF.standard_deviation(test_data)
            }
          end)
        end)

      results = Enum.map(tasks, &Task.await/1)

      # All results should be identical
      first_result = List.first(results)

      Enum.each(results, fn result ->
        assert result.mean == first_result.mean
        assert result.median == first_result.median
        assert result.std_dev == first_result.std_dev
      end)
    end

    test "number to words conversion is thread-safe" do
      numbers = [1, 123, 1234, 12345, 123_456]

      tasks =
        Enum.map(numbers, fn number ->
          Task.async(fn ->
            {number, NumberF.to_words(number, "Dollar", "Cent")}
          end)
        end)

      results = Enum.map(tasks, &Task.await/1)

      # Verify results
      expected_pairs = [
        {1, "One Dollar"},
        {123, "One Hundred Twenty Three Dollar"},
        {1234, "One Thousand Two Hundred Thirty Four Dollar"},
        {12345, "Twelve Thousand Three Hundred Forty Five Dollar"},
        {123_456, "One Hundred Twenty Three Thousand Four Hundred Fifty Six Dollar"}
      ]

      Enum.each(expected_pairs, fn {number, expected} ->
        {_, actual} = Enum.find(results, fn {n, _} -> n == number end)
        assert actual == expected
      end)
    end

    test "random generation produces different results across processes" do
      # Generate random strings concurrently
      tasks =
        Enum.map(1..100, fn _ ->
          Task.async(fn ->
            NumberF.randomizer(10, :all)
          end)
        end)

      results = Enum.map(tasks, &Task.await/1)

      # All should be different (statistically very likely)
      unique_results = Enum.uniq(results)
      # Should have > 90% unique results
      assert length(unique_results) > 90
    end

    test "tax calculations are thread-safe" do
      amounts = [100, 500, 1000, 5000, 10000]

      tasks =
        Enum.map(amounts, fn amount ->
          Task.async(fn ->
            {
              amount,
              NumberF.calculate_vat(amount, 0.2),
              NumberF.calculate_sales_tax(amount, 0.06)
            }
          end)
        end)

      results = Enum.map(tasks, &Task.await/1)

      # Verify calculations are correct
      Enum.each(results, fn {amount, vat, sales_tax} ->
        assert vat.net == amount
        assert vat.vat == amount * 0.2
        assert sales_tax.subtotal == amount
        assert sales_tax.tax == amount * 0.06
      end)
    end
  end
end
