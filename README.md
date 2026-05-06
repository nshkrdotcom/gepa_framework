# GEPA Framework

`gepa_framework` is the reusable optimizer framework for GEPA. It provides
typed config, component, runtime, candidate, evaluation, proposer, tracing, and
persistence-posture contracts without product repo dependencies or live provider
requirements.

The default checkpoint profile is `memory_ephemeral`. A result from this package
does not claim restart safety unless a later governed durable profile supplies
explicit evidence.
