defmodule NumberF.Financial do
  @moduledoc """
  Functions for financial calculations such as interest, EMI, and currency conversion.
  """

  @doc """
  Calculates simple interest.
  """
  def simple_interest(principal, rate, time)
      when is_number(principal) and is_number(rate) and is_number(time) and time >= 0 do
    Float.round(principal * rate * time, 2)
  end

  def simple_interest(principal, rate, time)
      when is_number(principal) and is_number(rate) and is_number(time) and time < 0 do
    raise ArgumentError, "time period cannot be negative, got: #{inspect(time)}"
  end

  def simple_interest(principal, rate, time) do
    raise ArgumentError,
          "simple_interest expects numbers, got: " <>
            "principal=#{inspect(principal)}, rate=#{inspect(rate)}, time=#{inspect(time)}"
  end

  @doc """
  Calculates compound interest.
  """
  def compound_interest(principal, rate, time, frequency)
      when is_number(principal) and is_number(rate) and is_number(time) and
             is_number(frequency) and frequency != 0 do
    Float.round(principal * :math.pow(1 + rate / frequency, frequency * time) - principal, 2)
  end

  def compound_interest(principal, rate, time, frequency) do
    raise ArgumentError,
          "compound_interest expects numbers with a non-zero frequency, got: " <>
            "principal=#{inspect(principal)}, rate=#{inspect(rate)}, " <>
            "time=#{inspect(time)}, frequency=#{inspect(frequency)}"
  end

  @doc """
  Calculates EMI (Equated Monthly Installment).
  """
  def calculate_emi(principal, rate, term_months)
      when is_number(principal) and is_number(rate) and is_number(term_months) and
             term_months > 0 do
    monthly_rate = rate / 12

    # An interest-free loan is a real product, and the standard annuity formula is
    # undefined for it: with rate 0 both the numerator and `power_term - 1` are 0,
    # so the general branch raised ArithmeticError. The limit as r approaches 0 is
    # simply the principal spread evenly across the term.
    emi =
      if monthly_rate == 0 do
        principal / term_months
      else
        power_term = :math.pow(1 + monthly_rate, term_months)
        principal * monthly_rate * power_term / (power_term - 1)
      end

    Float.round(emi, 2)
  end

  def calculate_emi(principal, rate, term_months) do
    raise ArgumentError,
          "calculate_emi expects numbers with term_months > 0, got: " <>
            "principal=#{inspect(principal)}, rate=#{inspect(rate)}, " <>
            "term_months=#{inspect(term_months)}"
  end

  @doc """
  Converts currency based on exchange rates.
  """
  def convert_currency(amount, from_rate, to_rate)
      when is_number(amount) and is_number(from_rate) and is_number(to_rate) and
             from_rate > 0 and to_rate > 0 do
    Float.round(amount * to_rate / from_rate, 2)
  end

  def convert_currency(amount, from_rate, to_rate) do
    raise ArgumentError,
          "convert_currency expects numbers with positive rates, got: " <>
            "amount=#{inspect(amount)}, from_rate=#{inspect(from_rate)}, to_rate=#{inspect(to_rate)}"
  end

  @doc """
  Present value of a future sum discounted at a periodic rate.

  ## Examples

      iex> NumberF.Financial.present_value(1000, 0.05, 10)
      613.91
  """
  def present_value(future_value, rate, periods)
      when is_number(future_value) and is_number(rate) and is_number(periods) do
    Float.round(future_value / :math.pow(1 + rate, periods), 2)
  end

  @doc """
  Future value of a present sum compounded at a periodic rate.

  ## Examples

      iex> NumberF.Financial.future_value(1000, 0.05, 10)
      1628.89
  """
  def future_value(present_value, rate, periods)
      when is_number(present_value) and is_number(rate) and is_number(periods) do
    Float.round(present_value * :math.pow(1 + rate, periods), 2)
  end

  @doc """
  Net present value of a series of cash flows.

  The first element is treated as occurring at t=0 and is not discounted, which is
  the convention a negative initial investment implies.

  ## Examples

      iex> NumberF.Financial.npv(0.1, [-1000, 300, 400, 500, 600])
      388.77
  """
  def npv(rate, cash_flows) when is_number(rate) and is_list(cash_flows) do
    cash_flows
    |> Enum.with_index()
    |> Enum.reduce(0.0, fn {flow, period}, acc -> acc + flow / :math.pow(1 + rate, period) end)
    |> Float.round(2)
  end

  @doc """
  Internal rate of return: the discount rate at which `npv/2` is zero.

  Returns `{:ok, rate}` or `{:error, :no_convergence}`.

  ## Edge cases

  Solved numerically by bisection, so it needs the cash flows to change sign at
  least once — an all-positive or all-negative series has no IRR and returns
  `{:error, :no_sign_change}`. A series that changes sign more than once can have
  several mathematically valid answers; this returns the one in `-0.9999..10`.

  ## Examples

      iex> {:ok, rate} = NumberF.Financial.irr([-1000, 300, 400, 500, 600])
      iex> Float.round(rate, 4)
      0.2489
  """
  def irr(cash_flows, options \\ []) when is_list(cash_flows) do
    tolerance = Keyword.get(options, :tolerance, 1.0e-7)
    max_iterations = Keyword.get(options, :max_iterations, 200)

    # Bisection needs the NPV to straddle zero, which it can only do if the flows
    # themselves change sign. An all-positive series has no rate that zeroes it.
    sign_change? = Enum.any?(cash_flows, &(&1 > 0)) and Enum.any?(cash_flows, &(&1 < 0))

    if sign_change? do
      bisect_irr(cash_flows, -0.9999, 10.0, tolerance, max_iterations)
    else
      {:error, :no_sign_change}
    end
  end

  defp bisect_irr(_flows, _low, _high, _tolerance, 0), do: {:error, :no_convergence}

  defp bisect_irr(flows, low, high, tolerance, iterations) do
    mid = (low + high) / 2
    value = raw_npv(flows, mid)

    cond do
      abs(value) < tolerance -> {:ok, mid}
      value > 0 -> bisect_irr(flows, mid, high, tolerance, iterations - 1)
      true -> bisect_irr(flows, low, mid, tolerance, iterations - 1)
    end
  end

  # Unrounded, unlike npv/2: rounding to 2 decimals inside the solver would stall
  # the bisection long before it reached the requested tolerance.
  defp raw_npv(cash_flows, rate) do
    cash_flows
    |> Enum.with_index()
    |> Enum.reduce(0.0, fn {flow, period}, acc -> acc + flow / :math.pow(1 + rate, period) end)
  end

  @doc """
  Full amortization schedule for a loan, one entry per period.

  Each entry gives the payment, how much of it is principal, how much is interest,
  and the balance remaining afterwards.

  ## Precision

  The final period absorbs any accumulated rounding so the balance closes at
  exactly zero, which is what a lender's schedule does.

  ## Examples

      iex> schedule = NumberF.Financial.amortization_schedule(100_000, 0.10, 12)
      iex> length(schedule)
      12
      iex> List.last(schedule).balance
      0.0
  """
  def amortization_schedule(principal, annual_rate, term_months)
      when is_number(principal) and is_number(annual_rate) and is_integer(term_months) and
             term_months > 0 do
    payment = calculate_emi(principal, annual_rate, term_months)
    monthly_rate = annual_rate / 12

    {schedule, _balance} =
      Enum.map_reduce(1..term_months, principal * 1.0, fn period, balance ->
        interest = Float.round(balance * monthly_rate, 2)

        # The last row pays off whatever is actually left, so pennies lost to
        # per-period rounding cannot leave a residual balance behind.
        {principal_part, payment_for_period} =
          if period == term_months do
            {balance, Float.round(balance + interest, 2)}
          else
            {Float.round(payment - interest, 2), payment}
          end

        new_balance = Float.round(balance - principal_part, 2)

        {%{
           period: period,
           payment: payment_for_period,
           principal: principal_part,
           interest: interest,
           balance: new_balance
         }, new_balance}
      end)

    schedule
  end

  @doc """
  Return on investment, as a percentage.

  ## Examples

      iex> NumberF.Financial.roi(1500, 1000)
      50.0
  """
  def roi(_gain, 0), do: raise(ArgumentError, "cost cannot be zero")
  def roi(_gain, +0.0), do: raise(ArgumentError, "cost cannot be zero")

  def roi(gain, cost) when is_number(gain) and is_number(cost) do
    Float.round((gain - cost) / cost * 100, 2)
  end

  @doc """
  Compound annual growth rate, as a percentage.

  ## Examples

      iex> NumberF.Financial.cagr(1000, 2000, 5)
      14.87
  """
  def cagr(beginning_value, ending_value, years)
      when is_number(beginning_value) and is_number(ending_value) and is_number(years) and
             beginning_value > 0 and years > 0 do
    Float.round((:math.pow(ending_value / beginning_value, 1 / years) - 1) * 100, 2)
  end

  def cagr(beginning_value, ending_value, years) do
    raise ArgumentError,
          "cagr requires a positive beginning value and positive years, got: " <>
            "#{inspect(beginning_value)}, #{inspect(ending_value)}, #{inspect(years)}"
  end

  @doc """
  Effective annual rate for a nominal rate compounded n times per year.

  ## Examples

      iex> NumberF.Financial.effective_annual_rate(0.12, 12)
      0.1268
  """
  def effective_annual_rate(nominal_rate, compounds_per_year)
      when is_number(nominal_rate) and is_number(compounds_per_year) and compounds_per_year > 0 do
    Float.round(
      :math.pow(1 + nominal_rate / compounds_per_year, compounds_per_year) - 1,
      4
    )
  end

  @doc """
  Level payment for a loan. A zero-rate-safe alias for `calculate_emi/3`.

  ## Examples

      iex> NumberF.Financial.loan_payment(100_000, 0.0, 12)
      8333.33
  """
  def loan_payment(principal, annual_rate, term_months),
    do: calculate_emi(principal, annual_rate, term_months)

  @doc """
  Payment required to amortise a present value over n periods.

  ## Examples

      iex> NumberF.Financial.annuity_payment(10_000, 0.05, 10)
      1295.05
  """
  def annuity_payment(present_value, rate, periods)
      when is_number(present_value) and is_number(rate) and is_number(periods) and periods > 0 do
    if rate == 0 do
      Float.round(present_value / periods, 2)
    else
      Float.round(present_value * rate / (1 - :math.pow(1 + rate, -periods)), 2)
    end
  end

  @doc """
  Present value of a stream of equal payments.

  ## Examples

      iex> NumberF.Financial.annuity_present_value(100, 0.05, 10)
      772.17
  """
  def annuity_present_value(payment, rate, periods)
      when is_number(payment) and is_number(rate) and is_number(periods) do
    if rate == 0 do
      Float.round(payment * periods * 1.0, 2)
    else
      Float.round(payment * (1 - :math.pow(1 + rate, -periods)) / rate, 2)
    end
  end

  @doc """
  Future value of a stream of equal payments.

  ## Examples

      iex> NumberF.Financial.annuity_future_value(100, 0.05, 10)
      1257.79
  """
  def annuity_future_value(payment, rate, periods)
      when is_number(payment) and is_number(rate) and is_number(periods) do
    if rate == 0 do
      Float.round(payment * periods * 1.0, 2)
    else
      Float.round(payment * (:math.pow(1 + rate, periods) - 1) / rate, 2)
    end
  end

  @doc """
  Straight-line depreciation per year.

  ## Examples

      iex> NumberF.Financial.depreciation_straight_line(10_000, 1_000, 5)
      1800.0
  """
  def depreciation_straight_line(cost, salvage, life_years)
      when is_number(cost) and is_number(salvage) and is_number(life_years) and life_years > 0 do
    Float.round((cost - salvage) / life_years, 2)
  end

  @doc """
  Declining-balance depreciation schedule, one entry per year.

  `factor` defaults to 2, giving the double-declining-balance method. Depreciation
  stops at the salvage value.

  ## Examples

      iex> schedule = NumberF.Financial.depreciation_declining_balance(10_000, 1_000, 5)
      iex> hd(schedule)
      %{year: 1, depreciation: 4000.0, book_value: 6000.0}
  """
  def depreciation_declining_balance(cost, salvage, life_years, factor \\ 2)
      when is_number(cost) and is_number(salvage) and is_integer(life_years) and life_years > 0 do
    rate = factor / life_years

    {schedule, _book} =
      Enum.map_reduce(1..life_years, cost * 1.0, fn year, book_value ->
        # Never depreciate below salvage: the asset is worth that much at disposal.
        depreciation = Float.round(min(book_value * rate, book_value - salvage), 2)
        depreciation = max(depreciation, 0.0)
        new_book = Float.round(book_value - depreciation, 2)

        {%{year: year, depreciation: depreciation, book_value: new_book}, new_book}
      end)

    schedule
  end

  @doc """
  Units that must be sold to cover fixed costs.

  ## Examples

      iex> NumberF.Financial.break_even_point(10_000, 25, 15)
      1000.0
  """
  def break_even_point(fixed_costs, price_per_unit, variable_cost_per_unit)
      when is_number(fixed_costs) and is_number(price_per_unit) and
             is_number(variable_cost_per_unit) do
    margin = price_per_unit - variable_cost_per_unit

    if margin <= 0 do
      raise ArgumentError,
            "price per unit must exceed variable cost per unit, got #{price_per_unit} and " <>
              "#{variable_cost_per_unit}"
    end

    Float.round(fixed_costs / margin, 2)
  end

  @doc """
  Years until cumulative cash flows repay an initial investment.

  Interpolates within the year the investment is recovered. Returns
  `{:error, :never_recovered}` when the flows never add up to the investment.

  ## Examples

      iex> NumberF.Financial.payback_period(1000, [300, 400, 500])
      {:ok, 2.6}
  """
  def payback_period(initial_investment, cash_flows)
      when is_number(initial_investment) and is_list(cash_flows) do
    if Enum.sum(cash_flows) < initial_investment do
      {:error, :never_recovered}
    else
      {years, _remaining} =
        Enum.reduce_while(cash_flows, {0, initial_investment * 1.0}, fn flow, {year, left} ->
          if flow >= left do
            {:halt, {year + left / flow, 0.0}}
          else
            {:cont, {year + 1, left - flow}}
          end
        end)

      {:ok, Float.round(years, 2)}
    end
  end
end
