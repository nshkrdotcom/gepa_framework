# StackLab Acceptance

StackLab proves GEPA Framework through `examples/gepa_platform_roundtrip`.

The proof must show:

- Mezzanine calls GEPA through `Mezzanine.AIExecution.OptimizerAdapter`;
- candidate refs preserve context packet, route, eval, cost, and trace refs;
- AppKit exposes only product-safe optimization projections;
- no active proof path depends on the retired `gepa_buildout` domain app;
- raw prompts, provider payloads, and credentials do not appear in receipts.

StackLab owns the proof matrix and scanners. GEPA owns package tests and its
adapter implementation.
