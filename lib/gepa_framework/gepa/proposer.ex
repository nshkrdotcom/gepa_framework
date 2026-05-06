defmodule GEPAFramework.GEPA.Proposer do
  @moduledoc """
  Candidate proposer contract and deterministic local proposer.
  """

  alias GEPAFramework.{Component, Value}
  alias GEPAFramework.GEPA.{Candidate, State}

  @callback propose(State.t()) :: {:ok, Candidate.t()} | :none | {:error, term()}

  @spec propose(State.t()) :: {:ok, Candidate.t()} | {:error, term()}
  def propose(%State{} = state) do
    components = Map.new(state.config.components, &Component.to_candidate_entry/1)

    first_ref =
      state.config.components
      |> List.first()
      |> case do
        %Component{component_ref: component_ref} -> component_ref
        _other -> "component:unknown"
      end

    Candidate.wrap(%{
      candidate_ref: "candidate:" <> first_ref,
      components: components,
      lineage_refs: ["lineage:" <> state.run_ref],
      diff_refs: ["diff:" <> first_ref],
      parent_refs: [],
      merge_refs: merge_refs(state),
      objective_refs: Value.string_list(Value.get(state.config.evaluator, :objective_refs, [])),
      rejection_reasons: [],
      checkpoint: state.config.persistence,
      trace_refs: state.trace_refs
    })
  end

  defp merge_refs(%State{} = state) do
    case Value.get(state.config.merge, :merge_ref) do
      ref when is_binary(ref) -> [ref]
      _other -> []
    end
  end
end
