# AGENTS.md

## Purpose

`gepa_framework` owns the reusable GEPA optimizer framework extracted from the
source evidence in `/home/home/p/g/n/gepa_ex`.

## Boundaries

- Own optimizer config, runtime, components, candidates, proposers,
  evaluators, tracing refs, and persistence posture.
- Do not own platform authority, provider credentials, promotion gates, product
  UX, or governed Mezzanine/Jido orchestration.
- Do not add provider SDKs, durable store defaults, dynamic atom creation,
  ambient env reads, or pattern-engine code.
- `gepa_framework` is not in the Weld consumer set. Do not add a Weld
  dependency, Weld task, or Weld Credo check as part of Phase 2 cleanup.

## Dependency Sources

- Cross-repo dependency selection belongs in
  `build_support/dependency_sources.config.exs` and is consumed through the
  canonical `build_support/dependency_sources.exs` helper.
- This repo currently has no cross-repo dependencies; the dependency-source
  manifest is intentionally empty.
- Machine-local dependency overrides belong in `.dependency_sources.local.exs`.
  Keep that file untracked.
- Dependency source selection must not read environment variables.

## Runtime Environment

- Runtime application code under `lib/**` must not call direct OS environment
  APIs such as `System.get_env/1`, `System.fetch_env/1`,
  `System.fetch_env!/1`, `System.put_env/2`, `System.delete_env/1`, or
  `System.get_env/0`.
- Deployment environment reads belong at OTP boot boundaries such as
  `config/runtime.exs` or a `Config.Provider`. Runtime modules should receive
  explicit options or materialized application config.

## Verification

Run from the repo root:

```bash
mix ci
```
