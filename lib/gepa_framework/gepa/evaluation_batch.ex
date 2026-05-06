defmodule GEPAFramework.GEPA.EvaluationBatch do
  @moduledoc """
  Deterministic evaluation-batch evidence for local framework proofs.
  """

  alias GEPAFramework.GEPA.Candidate

  @type t :: %__MODULE__{
          batch_ref: String.t(),
          candidate_ref: String.t(),
          example_refs: [String.t()],
          objective_refs: [String.t()],
          score: float()
        }

  @enforce_keys [:batch_ref, :candidate_ref]
  defstruct [:batch_ref, :candidate_ref, example_refs: [], objective_refs: [], score: 1.0]

  @spec new(Candidate.t(), [term()], [String.t()]) :: t()
  def new(%Candidate{} = candidate, examples, objective_refs) do
    %__MODULE__{
      batch_ref: "batch:" <> candidate.candidate_ref,
      candidate_ref: candidate.candidate_ref,
      example_refs: Enum.filter(examples, &is_binary/1),
      objective_refs: objective_refs,
      score: 1.0
    }
  end
end
