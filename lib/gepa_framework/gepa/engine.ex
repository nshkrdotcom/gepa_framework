defmodule GEPAFramework.GEPA.Engine do
  @moduledoc """
  Deterministic local GEPA engine proof.
  """

  alias GEPAFramework.{Config, Value}
  alias GEPAFramework.GEPA.{EvaluationBatch, Proposer, Result, State}

  @spec run(Config.t(), keyword()) :: {:ok, Result.t()} | {:error, term()}
  def run(%Config{} = config, opts \\ []) do
    examples =
      Keyword.get(
        opts,
        :examples,
        Value.string_list(Value.get(config.data_loader, :example_refs, []))
      )

    state = State.new(config, examples)

    with {:ok, candidate} <- Proposer.propose(state) do
      objectives = Value.string_list(Value.get(config.evaluator, :objective_refs, []))
      evaluation_batch = EvaluationBatch.new(candidate, examples, objectives)

      {:ok,
       %Result{
         run_ref: config.runtime_ref,
         runtime_spec: Config.to_runtime_spec(config),
         candidate_refs: [candidate.candidate_ref],
         best_candidate_ref: candidate.candidate_ref,
         candidates: [candidate],
         evaluation_batches: [evaluation_batch],
         checkpoint: config.persistence,
         trace_refs: config.tracing.trace_refs,
         provider_dependency?: false
       }}
    end
  end
end
