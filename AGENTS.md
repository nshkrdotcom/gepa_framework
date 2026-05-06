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

## Verification

Run from the repo root:

```bash
mix ci
```
