# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 0.2.x   | ✅ |
| 0.1.x   | ❌ |

Only the latest minor release receives security fixes. Upgrade to the current version
before reporting an issue.

## Reporting a vulnerability

**Do not open a public GitHub issue for a security vulnerability.**

Report privately through
[GitHub Security Advisories](https://github.com/jamesnjovu/elixir_number_functions/security/advisories/new),
or by email to njovujames@gmail.com with `SECURITY` in the subject line.

Please include:

- the affected version,
- a description of the issue and its impact,
- steps to reproduce, ideally a minimal Elixir snippet.

You can expect an acknowledgement within 7 days and an assessment within 30 days. Fixes
are released as a patch version, credited to the reporter unless anonymity is requested.

## Scope

NumberF is a pure-computation library. It makes no network calls, opens no files, spawns
no processes, and reads no configuration. The realistic risk surface is therefore:

- incorrect numeric results in financial, tax, or precision functions,
- denial of service through unbounded input (very large integers, long strings),
- vulnerabilities in the sole runtime dependency, `decimal`.

Note on validation: `is_valid_credit_card?/1` implements the Luhn checksum only. It
verifies that a number is well-formed; it does not authenticate a card. Never store raw
card numbers — delegate authorization to a PCI-compliant payment processor.

Note on tax: the built-in rates and brackets are reference data and change over time.
Supply your own current rates for anything with legal or financial consequence.

## Dependency auditing

The repository runs `mix deps.audit` (via `mix_audit`) in CI on every push and nightly.
