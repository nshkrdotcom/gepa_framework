<p align="center">
  <img src="assets/gepa_framework.svg" alt="GEPA Framework" width="220" />
</p>

<p align="center">
  <a href="https://github.com/nshkrdotcom/gepa_framework"><img alt="GitHub" src="https://img.shields.io/badge/github-nshkrdotcom%2Fgepa__framework-24292f?logo=github" /></a>
  <img alt="Elixir" src="https://img.shields.io/badge/elixir-1.17%2B-4b275f?logo=elixir" />
  <img alt="Weld" src="https://img.shields.io/badge/weld-0.8.0-2563eb" />
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
