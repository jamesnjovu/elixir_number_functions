# AGENTS.md

Guidance for AI coding agents (Claude Code, Cursor, Codex, Copilot, Aider) working in
this repository. Humans should start with [CONTRIBUTING.md](CONTRIBUTING.md).

## What this project is

`number_f` — an Elixir library published on Hex providing number formatting, currency
formatting, number-to-words conversion, financial and tax calculations, statistics,
validation, and unit conversion. It is a **library**, not an application: there is no
server to run, no database, and no external service to configure.

## Layout

```
lib/number_f.ex          Flat public facade. Every user-facing function is delegated from here.
lib/number_f/*.ex        Implementation modules (currency, i18n, tax, financial, precision, ...).
lib/mix/tasks/           Custom mix tasks: test.numberf_fast, test.numberf_all.
guides/                  HexDocs extras, including cheatsheet.cheatmd and faq.md.
test/                    Unit tests mirror lib/. Also property/, integration/, performance/.
llms.txt                 LLM-readable summary of the library (llmstxt.org convention).
```

## Commands

```bash
mix deps.get
mix test                 # default suite (performance tests excluded)
mix test.numberf_fast    # excludes performance, benchmark, property
mix test.numberf_all     # everything
mix format               # required before committing
mix lint                 # format + compile --warnings-as-errors + credo --strict
mix dialyzer             # must be clean
mix coveralls            # must clear the ratchet in coveralls.json
mix docs                 # builds HTML + llms.txt into doc/; must emit zero warnings
mix deps.audit           # security audit
```

## Conventions

- **Implement in the submodule; `defdelegate` from `NumberF`.** The facade is
  documentation plus delegation — 261 arities, one real function. Never reimplement a
  submodule function in the facade: doing exactly that is how three modules ended up
  with zero callers and behaviour that had silently drifted from their facade twins.
- **Every public submodule function must be reachable from `NumberF`.**
  `test/number_f/facade_surface_test.exs` derives the expected surface from the
  submodules, so a missing delegation fails CI. If a name is too generic for a flat
  namespace, expose it under a clearer one and add it to that test's `@renamed` map.
- **Every facade function needs `@doc group:`.** It generates the docs sidebar via
  `groups_for_docs` in `mix.exs`. `test/docs_match_code_test.exs` enforces this.
- **Every public function needs a `@doc` with a `## Examples` section.** Doctests are
  collected by `test/doctests/doctest_runner_test.exs`, so examples are executed, not
  decorative.
- **Verify example output by running it, never by reasoning about it.** A v0.2.0 audit
  found five documented outputs the library did not produce, plus two functions that
  hardcoded their own doctest input so the test passed while exercising nothing.
  Several parameters are also not what they look like: `ceiling/2` and `floor/2` take
  decimal places, while `round_to/3` takes an increment; `bankers_round(2.5)` is `2.5`,
  not `2.0`, because precision defaults to 2.
- **The cheatsheet is executed by the test suite.** Every `# =>` in
  `guides/cheatsheet.cheatmd` must be a real Elixir term, or elided with `...`, or
  carry a two-space-separated aside marking it unassertable (`random`, `today`).
  Prose in the value position fails the build.
- **Error contract:** invalid input raises `ArgumentError` naming the offending
  argument. Never let a `FunctionClauseError` or `ArithmeticError` escape a public
  function. Genuinely fallible parsers may return `{:ok, _}` / `{:error, _}`.
  Formatters accept `nil` and return `nil`.
- **`variance/1` and `standard_deviation/1` are the population forms.** The `sample_*`
  variants divide by N-1. Say which one a new statistical function uses.
- **Do not add runtime dependencies.** `decimal` is the only one, and that is a
  deliberate selling point. `ex_doc` and `mix_audit` are dev/test only.
- **No network calls at runtime.** Exchange rates and tax rates are always supplied by
  the caller.
- Follow the existing naming: predicates are `is_*?/1` (e.g. `is_valid_credit_card?/1`),
  not bare `valid_*?`.

## When changing documentation

`README.md`, `llms.txt`, the moduledoc in `lib/number_f.ex`, and `guides/cheatsheet.cheatmd`
all carry examples and the install version. Keep them consistent with each other and with
`@version` in `mix.exs`, and re-run any example you change.

Do not create a `README.md` inside `.github/` — GitHub renders that in preference to the
root README, which would hide the project's landing page.

## Releasing

Maintainer-only. Bump `@version` in `mix.exs`, add a dated `CHANGELOG.md` entry, tag
`vX.Y.Z`, and let `.github/workflows/release.yml` publish. Do not run `mix hex.publish`
from an agent session.
