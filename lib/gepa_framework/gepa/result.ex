defmodule GEPAFramework.GEPA.Result do
  @moduledoc """
  Result container for deterministic framework GEPA runs.
  """

  alias GEPAFramework.GEPA.{Candidate, EvaluationBatch}
  alias GEPAFramework.Persistence

  @type t :: %__MODULE__{
          run_ref: String.t(),
          runtime_spec: map(),
          candidate_refs: [String.t()],
          best_candidate_ref: String.t() | nil,
          candidates: [Candidate.t()],
          evaluation_batches: [EvaluationBatch.t()],
          checkpoint: Persistence.t(),
          trace_refs: [String.t()],
          provider_dependency?: boolean()
        }

  @enforce_keys [:run_ref, :runtime_spec, :checkpoint]
  defstruct [
    :run_ref,
    :runtime_spec,
    candidate_refs: [],
    best_candidate_ref: nil,
    candidates: [],
    evaluation_batches: [],
    checkpoint: Persistence.default(),
    trace_refs: [],
    provider_dependency?: false
  ]
end
