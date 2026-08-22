# Frequently Asked Questions

## What is NumberF?

NumberF is an Elixir library (published on Hex as `number_f`) for number formatting,
currency formatting, number-to-words conversion, financial and tax calculations,
statistics, validation, and unit conversion. It exposes everything through a single
flat `NumberF` module and has one runtime dependency, `decimal`.

## How do I install NumberF in an Elixir or Phoenix project?

Add it to `deps` in `mix.exs` and run `mix deps.get`:

```elixir
def deps do
  [{:number_f, "~> 0.3.0"}]
end
```

There is nothing to configure and nothing to add to your supervision tree. In a Phoenix
project you can call `NumberF` functions directly from controllers, contexts, LiveViews,
and HEEx templates.

## What is the minimum Elixir version?

Elixir 1.14 or later.

## Does NumberF work with Decimal?

Yes, for the operations where exactness matters. `NumberF.to_decimal/1` converts values
into `Decimal` structs, and `NumberF.sum_decimal/1` sums a list of them without
floating-point drift:

```elixir
NumberF.sum_decimal([Decimal.new("1.10"), Decimal.new("2.20")])
# => Decimal.new("3.30")
```

Most other functions operate on native integers and floats. If you are handling money
in a domain where every fraction of a cent is legally significant, keep the canonical
value in `Decimal` (or in integer minor units) and use NumberF for the display layer.

## Should I use NumberF or ex_cldr / ex_money?

Pick based on how deep you need to go in one area:

- **NumberF** — breadth. One small dependency covering formatting, finance, tax,
  statistics, validation, dates and unit conversion. Best when you need "a bit of
  everything" and do not want five dependencies.
- **[ex_cldr](https://hex.pm/packages/ex_cldr)** — depth in localization. Full Unicode
  CLDR data. Use it when locale correctness across hundreds of locales is a hard
  requirement or an audited one.
- **[ex_money](https://hex.pm/packages/ex_money) / [money](https://hex.pm/packages/money)** —
  depth in money. A real `Money` type with currency-safe arithmetic. Use these when money
  is a first-class type in your domain model rather than a formatting concern.

These are not mutually exclusive. A common setup is `ex_money` for the domain type and
NumberF for the assorted numeric utilities around it.

## How many locales does NumberF support?

22. The full list is `en-US`, `en-GB`, `en-ZM`, `fr-FR`, `de-DE`, `es-ES`, `it-IT`,
`nl-NL`, `pl-PL`, `sv-SE`, `pt-BR`, `ru-RU`, `tr-TR`, `ar-SA`, `hi-IN`, `ja-JP`,
`ko-KR`, `zh-CN`, `th-TH`, `vi-VN`, `id-ID`, and `ms-MY`. Each carries its own
thousands separator, decimal separator, currency symbol, and symbol placement.

```elixir
NumberF.format_number(1234567.89, "de-DE")   # => "1.234.567,89"
NumberF.format_currency(1234.56, "fr-FR")    # => "1 234,56 €"
```

Number-to-words spelling is available in English, French, Spanish, and German via
`NumberF.spell_number/2`.

## Why is the default currency ZMW?

The library originated in Zambia, so `NumberF.currency/1` and `NumberF.to_words/1`
default to Zambian Kwacha. Pass the unit explicitly to override:

```elixir
NumberF.currency(1234.5)          # => "ZMW 1,234.50"
NumberF.currency(1234.5, "USD")   # => "USD 1,234.50"
NumberF.to_words(42, "Dollars", "Cents")
```

## How do I round money correctly?

Use `NumberF.bankers_round/2` (round half to even). Always rounding `.5` upward
introduces a systematic upward bias that becomes visible across large batches of
transactions, which is why banking and accounting standards specify round-half-to-even.

```elixir
NumberF.bankers_round(2.5, 0)   # => 2.0
NumberF.bankers_round(3.5, 0)   # => 4.0
```

Note that `ceiling/2` and `floor/2` take a number of **decimal places**, while
`round_to/3` takes an **increment** (for example, rounding to the nearest 0.05).

## Why should I not compare floats with ==?

Because `0.1 + 0.2 == 0.3` is `false` in every IEEE 754 language, Elixir included.
Use `NumberF.approximately_equal/3` with an explicit tolerance:

```elixir
NumberF.approximately_equal(0.1 + 0.2, 0.3)   # => true
```

## Is NumberF safe to use for credit card validation?

`NumberF.is_valid_credit_card?/1` implements the Luhn checksum. That confirms a number
is well-formed — it catches typos and transposed digits. It does **not** confirm that
the card exists, is active, or has funds. Never store raw card numbers; delegate real
authorization to a PCI-compliant payment processor.

## Does NumberF fetch live exchange rates?

No. `NumberF.convert_currency/3` takes the rates you supply, so the library makes no
network calls and has no hidden runtime dependency on an external service. Fetch rates
from whichever provider you trust and pass them in:

```elixir
NumberF.convert_currency(100, 1.0, 0.85)   # amount, from_rate, to_rate  => 85.0
```

## Are the tax calculations legally authoritative?

No. The tax functions implement the standard arithmetic for VAT, sales tax, progressive
income tax, capital gains, withholding, corporate and payroll tax, and ship with a set
of reference rates and brackets. Rates change, jurisdictions differ, and edge cases
abound. Treat the built-in tables as a starting point, supply your own current rates for
anything that matters, and have a qualified accountant verify production tax logic.

## Can I use NumberF from a Phoenix HEEx template?

Yes:

```heex
<span class="price"><%= NumberF.format_currency(@product.price, @locale) %></span>
```

## Where can AI assistants get the full API?

The documentation is published in LLM-readable plain text following the
[llms.txt convention](https://llmstxt.org):

- <https://hexdocs.pm/number_f/llms.txt> — index of every page and module
- <https://hexdocs.pm/number_f/llms-full.txt> — the entire documentation as one file

Point Claude, ChatGPT, Cursor, or any retrieval pipeline at those URLs.

## How do I report a bug or request a feature?

Open an issue at
<https://github.com/jamesnjovu/elixir_number_functions/issues>. For security
vulnerabilities, follow the private process in
[SECURITY.md](https://github.com/jamesnjovu/elixir_number_functions/blob/master/SECURITY.md)
rather than opening a public issue.
