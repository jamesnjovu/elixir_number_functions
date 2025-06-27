# NumberF Test Suite

This document provides a comprehensive overview of the NumberF test suite and how to use it effectively.

## Test Suite Overview

The NumberF test suite consists of **800+ tests** across multiple categories, providing comprehensive coverage of all library functionality.

### Test Categories

| Category | Test Count | Purpose |
|----------|------------|---------|
| **Core Unit Tests** | 400+ | Test individual functions and modules |
| **Integration Tests** | 50+ | Test module interactions and workflows |
| **Edge Cases** | 150+ | Test boundary conditions and unusual inputs |
| **Performance Tests** | 25+ | Benchmark critical functions |
| **Error Handling** | 75+ | Test error scenarios and graceful failures |
| **Concurrency Tests** | 20+ | Verify thread safety |
| **Property Tests** | 30+ | Mathematical consistency validation |
| **Real-World Scenarios** | 50+ | Business use case simulations |

## Quick Start

```bash
# Run all tests
mix test

# Run with coverage report
mix test --cover

# Run fast tests only (excludes performance/benchmarks)
mix test --exclude performance --exclude benchmark

# Run specific module tests
mix test test/number_f_test.exs
```

## Test Organization

```
test/
├── number_f_test.exs                    # Main module tests
├── number_f/
│   ├── calculations_test.exs            # Mathematical calculations
│   ├── financial_test.exs               # Financial functions
│   ├── statistics_test.exs              # Statistical analysis
│   ├── currencies_test.exs              # Currency operations
│   ├── tax_test.exs                     # Tax calculations
│   ├── precision_test.exs               # Precision handling
│   ├── i18n_test.exs                    # Internationalization
│   └── ...
├── integration/
│   ├── real_world_scenarios_test.exs    # Business scenarios
│   └── integration_test.exs             # Module interactions
├── focused/
│   ├── rounding_test.exs                # Detailed rounding tests
│   ├── currency_edge_cases_test.exs     # Currency edge cases
│   └── ...
├── concurrency/
│   └── concurrent_operations_test.exs   # Thread safety tests
├── error_handling/
│   └── error_scenarios_test.exs         # Error condition tests
├── support/
│   ├── test_helper.exs                  # Test utilities
│   └── test_runner.ex                   # Test execution scripts
└── doctests/
    └── doctest_runner_test.exs          # Documentation tests
```

## Running Different Test Suites

### Development Workflow

```bash
# Quick feedback during development
mix test --exclude performance --exclude benchmark --exclude property

# Before committing
mix test --cover

# Full validation before release
mix test --include performance --include benchmark --include property --cover
```

### Continuous Integration

```bash
# Fast CI pipeline (< 30 seconds)
mix test --exclude performance --exclude benchmark

# Comprehensive CI pipeline (< 5 minutes)  
mix test --include performance --include benchmark --cover
```

### Performance Monitoring

```bash
# Run performance benchmarks
mix test --only performance

# Run detailed benchmarks
mix test --only benchmark
```

## Test Coverage Goals

- **Line Coverage**: 98%+ for all public functions
- **Branch Coverage**: 95%+ including error paths  
- **Function Coverage**: 100% of exported functions tested
- **Documentation**: All @doc examples validated via doctests

## Key Test Features

### 1. Property-Based Testing
```elixir
# Mathematical properties are verified
test "currency formatting is reversible" do
  amounts = generate_random_amounts(100)
  Enum.each(amounts, fn amount ->
    formatted = NumberF.currency(amount, "USD")
    # Verify format is correct and amount is preserved
  end)
end
```

### 2. Performance Benchmarking
```elixir
test "currency formatting performance" do
  {time, _} = :timer.tc(fn ->
    Enum.each(1..1000, &NumberF.currency(&1, "USD"))
  end)
  assert time < 100_000  # Should complete in < 100ms
end
```

### 3. Thread Safety Verification
```elixir
test "statistical calculations are thread-safe" do
  tasks = Enum.map(1..50, fn _ ->
    Task.async(fn -> NumberF.mean(test_data) end)
  end)
  results = Enum.map(tasks, &Task.await/1)
  # All results should be identical
end
```

### 4. Real-World Scenarios
```elixir
test "e-commerce pricing workflow" do
  # Complete pricing calculation including discounts, taxes, formatting
  base_price = 99.99
  # ... full business logic simulation
end
```

## Test Data Helpers

The test suite includes comprehensive helpers for generating test data:

```elixir
# Generate numerical test data
TestHelper.generate_test_data(1000)

# Create currency exchange rates
TestHelper.test_exchange_rates()

# Generate tax brackets
TestHelper.test_tax_brackets()

# Create test phone numbers for different countries
TestHelper.test_phone_numbers()
```

## Error Testing Strategy

All error paths are systematically tested:

- **Input Validation**: Invalid types, ranges, formats
- **Mathematical Errors**: Division by zero, overflow conditions  
- **Resource Limits**: Memory exhaustion, stack overflow
- **External Dependencies**: File system, network failures (if any)
- **Concurrency Issues**: Race conditions, deadlocks

## Performance Benchmarks

Key performance targets:

| Function | Target Performance |
|----------|-------------------|
| Currency formatting | < 50μs per operation |
| Statistical calculations | < 100ms for 10k items |
| Number to words | < 1000μs per conversion |
| Tax calculations | < 10μs per calculation |

## Memory Testing

Memory usage is monitored to prevent leaks:

```elixir
test "memory usage is reasonable" do
  :erlang.garbage_collect()
  memory_before = :erlang.memory(:total)
  
  # Perform operations
  large_dataset_operations()
  
  :erlang.garbage_collect()
  memory_after = :erlang.memory(:total)
  
  assert (memory_after - memory_before) < 10_000_000  # < 10MB
end
```

## Adding New Tests

When adding new functionality:

1. **Unit Tests**: Test the function in isolation
2. **Integration Tests**: Test interaction with other modules
3. **Edge Cases**: Test boundary conditions
4. **Error Cases**: Test error scenarios
5. **Performance**: Add benchmarks for critical functions
6. **Documentation**: Ensure doctests cover examples

### Example Test Template

```elixir
defmodule NumberF.NewFeatureTest do
  use ExUnit.Case
  doctest NumberF.NewFeature

  describe "new_function/2" do
    test "handles normal inputs" do
      assert NumberF.new_function(1, 2) == expected_result
    end

    test "handles edge cases" do
      assert NumberF.new_function(0, 0) == edge_case_result
    end

    test "raises on invalid input" do
      assert_raise ArgumentError, fn ->
        NumberF.new_function("invalid", "input")
      end
    end

    @tag :performance
    test "performance is acceptable" do
      {time, _} = :timer.tc(fn ->
        Enum.each(1..1000, fn i ->
          NumberF.new_function(i, i * 2)
        end)
      end)
      assert time < 50_000  # < 50ms for 1000 operations
    end
  end
end
```

## Troubleshooting Tests

### Common Issues

1. **Floating Point Precision**: Use `assert_in_delta/3` for float comparisons
2. **Random Test Failures**: Use fixed seeds for deterministic tests
3. **Performance Variations**: Allow reasonable variance in performance tests
4. **Concurrency Issues**: Ensure tests are independent and don't share state

### Debug Helpers

```elixir
# Enable debug output
ExUnit.configure(capture_log: false)

# Run single test with detailed output
mix test test/specific_test.exs:line_number --trace

# Check test coverage for specific module
mix test --cover test/number_f/calculations_test.exs
```

## Continuous Integration Configuration

### GitHub Actions Example

```yaml
name: Test Suite
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        elixir: [1.14, 1.15, 1.16]
        otp: [25, 26]
    
    steps:
    - uses: actions/checkout@v3
    - uses: erlef/setup-beam@v1
      with:
        elixir-version: ${{ matrix.elixir }}
        otp-version: ${{ matrix.otp }}
    
    - name: Install dependencies
      run: mix deps.get
    
    - name: Run fast tests
      run: mix test --exclude performance --exclude benchmark
    
    - name: Run comprehensive tests
      if: matrix.elixir == '1.16' && matrix.otp == '26'
      run: mix test --include performance --include benchmark --cover
```

## Test Metrics Dashboard

The test suite can generate metrics for monitoring:

- **Coverage Percentage**: Line and branch coverage
- **Performance Trends**: Track performance over time
- **Test Count**: Number of tests per category
- **Failure Rate**: Track test stability
- **Execution Time**: Monitor test suite performance

This comprehensive test suite ensures the NumberF library is robust, performant, and reliable for production use.
