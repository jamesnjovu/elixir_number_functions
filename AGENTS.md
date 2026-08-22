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
mix docs                 # builds HTML + llms.txt into doc/
mix deps.audit           # security audit
```

## Conventions

- **Add functions in the implementation module, then `defdelegate` (or a thin wrapper)
  from `NumberF`.** The flat facade is the documented API surface; a function that only
  exists on a submodule is effectively undiscoverable.
- **Every public function needs a `@doc` with a `## Examples` section.** Doctests are
  collected by `test/doctests/doctest_runner_test.exs`, so examples are executed, not
  decorative.
- **Verify example output by running it.** Several parameters are not what they look
  like: `ceiling/2` and `floor/2` take decimal places, while `round_to/3` takes an
  increment. `bankers_round/1` defaults to 2 decimal places, so `bankers_round(2.5)`
  is `2.5`, not `2.0`.
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
