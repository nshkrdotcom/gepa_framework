# GEPA QC And Operations

## Local QC

```bash
mix ci
```

The default QC path is deterministic and must not require provider credentials.

## Live Provider Posture

Live provider or vector-store integrations are opt-in through explicit runtime
dependencies. A deterministic fixture path must remain available for StackLab
and local CI.

## Release Posture

The root package is the Hex-ready projection surface. Guides are included in
package metadata so downstream users can inspect stack boundaries, promotion
rules, and QC expectations from generated docs.
