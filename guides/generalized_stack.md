# GEPA Generalized Stack Boundary

GEPA Framework owns reusable optimizer contracts and deterministic candidate
generation behavior. It is a platform component, not a product app.

## Owns

- optimizer config and strategy contracts;
- candidate, evaluation batch, result, and runtime structs;
- proposer and engine behavior;
- tracing and checkpoint posture contracts;
- `GEPA.MezzanineOptimizerAdapter` for Mezzanine adapter mode.

## Does Not Own

- product projections;
- Citadel authority;
- Mezzanine workflow truth;
- AppKit promotion decisions;
- provider credential materialization;
- live model routing policy.

## Stack Handoff

Mezzanine calls `GEPA.MezzanineOptimizerAdapter` through
`Mezzanine.AIExecution.OptimizerAdapter`. The adapter returns candidate refs and
bounded receipts. Mezzanine, Citadel, and AppKit remain responsible for
admission, authority, promotion, rollback, and product/operator readback.

The adapter is also the raw-payload firewall for GEPA stack mode. It accepts
optimization facts as refs, hashes, strategies, scores, and bounded metadata;
it rejects raw prompt/provider/memory fields, credentials, tokens,
authorization keys, and `raw_*` attrs recursively.
