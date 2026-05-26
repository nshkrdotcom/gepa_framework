<p align="center">
  <img src="assets/gepa_framework.svg" alt="GEPA Framework" width="220" />
</p>

<p align="center">
  <a href="https://github.com/nshkrdotcom/gepa_framework"><img alt="GitHub" src="https://img.shields.io/badge/github-nshkrdotcom%2Fgepa__framework-24292f?logo=github" /></a>
  <img alt="Elixir" src="https://img.shields.io/badge/elixir-1.17%2B-4b275f?logo=elixir" />
  <img alt="License" src="https://img.shields.io/badge/license-MIT-0f766e" />
</p>

# GEPA Framework

`gepa_framework` is the reusable optimizer framework for GEPA. It provides
typed config, component, runtime, candidate, evaluation, proposer, tracing, and
persistence-posture contracts without product repo dependencies or live provider
requirements.

The default checkpoint profile is `memory_ephemeral`. A result from this package
does not claim restart safety unless a later governed durable profile supplies
explicit evidence.

## Quickstart

```bash
git clone https://github.com/nshkrdotcom/gepa_framework
cd gepa_framework
mix deps.get
mix test
mix ci
```

The default test path is deterministic and does not require live provider
credentials.

## Mezzanine Adapter

`GEPA.MezzanineOptimizerAdapter` implements
`Mezzanine.AIExecution.OptimizerAdapter` for same-BEAM stack mode. It turns a
Mezzanine optimization request into deterministic GEPA candidate receipts while
preserving context packet, route decision, eval, cost, promotion, rollback, and
trace refs. The adapter never promotes a candidate or mutates production state;
Citadel, Mezzanine, and AppKit remain responsible for authority, promotion
truth, and product/operator projections.

The NSHKR cleanup pass hardened the adapter boundary. Optimization attrs are
recursively rejected when they contain `raw_*`, raw prompt/provider/memory
fields, credentials, authorization, tokens, or secrets. GEPA candidates should
carry refs, hashes, score summaries, and bounded failure reasons only.

## Guides

- `guides/generalized_stack.md`
- `guides/eval_and_promotion.md`
- `guides/stacklab_acceptance.md`
- `guides/qc_and_operations.md`
