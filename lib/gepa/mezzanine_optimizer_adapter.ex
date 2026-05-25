defmodule GEPA.MezzanineOptimizerAdapter do
  @moduledoc """
  Same-BEAM adapter from Mezzanine optimization requests into GEPA Framework.

  The adapter implements `Mezzanine.AIExecution.OptimizerAdapter` and returns
  candidate receipts only. It never promotes candidates or mutates production
  prompts, memory, routing policy, or model configuration.
  """

  @behaviour Mezzanine.AIExecution.OptimizerAdapter

  alias GEPAFramework.GEPA.{Candidate, Result}
  alias GEPAFramework.{Runtime, Value}
  alias Mezzanine.AIExecution.OptimizerAdapter
  alias OuterBrain.ContextABI.Failure

  @forbidden_raw_fields [
    :prompt,
    "prompt",
    :raw_prompt,
    "raw_prompt",
    :provider_payload,
    "provider_payload",
    :raw_provider_payload,
    "raw_provider_payload",
    :model_output,
    "model_output",
    :raw_model_output,
    "raw_model_output",
    :memory_body,
    "memory_body",
    :secret,
    "secret"
  ]

  @impl true
  @spec propose(OptimizerAdapter.optimization_request(), keyword()) ::
          {:ok, [OptimizerAdapter.candidate_receipt()]} | {:error, Failure.t()}
  def propose(optimization_request, opts \\ [])

  def propose(optimization_request, opts) when is_map(optimization_request) and is_list(opts) do
    with :ok <- reject_raw(optimization_request),
         {:ok, tenant_ref} <- required(optimization_request, :tenant_ref),
         {:ok, objective_ref} <- required(optimization_request, :objective_ref),
         {:ok, promotion_policy_ref} <- required(optimization_request, :promotion_policy_ref),
         {:ok, trace_ref} <- required(optimization_request, :trace_ref),
         {:ok, candidate_source_refs} <- candidate_sources(optimization_request),
         {:ok, %Result{} = result} <-
           Runtime.run(config(optimization_request, candidate_source_refs),
             examples: examples(opts)
           ) do
      {:ok,
       Enum.map(result.candidates, fn candidate ->
         receipt(
           candidate,
           result,
           optimization_request,
           tenant_ref,
           objective_ref,
           promotion_policy_ref,
           trace_ref
         )
       end)}
    end
  end

  def propose(_optimization_request, _opts),
    do:
      failure("gepa.optimization.invalid_request.v1",
        safe_message: "GEPA optimization request is invalid"
      )

  @doc false
  @spec behaviour_contract() :: module()
  def behaviour_contract, do: OptimizerAdapter

  defp config(request, candidate_source_refs) do
    objective_ref = fetch(request, :objective_ref)
    trace_ref = fetch(request, :trace_ref)

    [
      runtime_ref: runtime_ref(request),
      task: %{
        task_ref: fetch(request, :optimization_target_ref) || objective_ref,
        dataset_ref:
          first_ref(request, :eval_refs) || first_ref(request, :eval_dataset_refs) ||
            objective_ref
      },
      components: components(candidate_source_refs),
      evaluator: %{
        evaluator_ref: objective_ref,
        objective_refs: [objective_ref],
        eval_refs: string_list(request, :eval_refs),
        cost_refs: string_list(request, :cost_refs)
      },
      proposer: %{
        proposer_ref: fetch(request, :proposer_ref) || "proposer:gepa:mezzanine",
        strategy: :deterministic_reflection
      },
      merge: %{
        merge_ref: fetch(request, :merge_ref) || "merge:gepa:mezzanine:disabled",
        strategy: :disabled
      },
      tracing: %{trace_refs: [trace_ref]},
      persistence: %{profile: :memory_ephemeral}
    ]
  end

  defp components(candidate_source_refs) do
    candidate_source_refs
    |> Enum.with_index(1)
    |> Enum.map(fn {source_ref, index} ->
      %{
        component_ref: "component:gepa:mezzanine:" <> Integer.to_string(index),
        kind: :component,
        content_ref: source_ref
      }
    end)
  end

  defp receipt(
         %Candidate{} = candidate,
         %Result{} = result,
         request,
         tenant_ref,
         objective_ref,
         promotion_policy_ref,
         trace_ref
       ) do
    promotion_ref = fetch(request, :promotion_ref)
    rollback_ref = fetch(request, :rollback_ref)

    %{
      candidate_ref: candidate.candidate_ref,
      lineage_refs: candidate.lineage_refs,
      objective_score_ref: objective_score_ref(candidate, objective_ref),
      promotion_required?: true,
      trace_ref: trace_ref,
      tenant_ref: tenant_ref,
      objective_ref: objective_ref,
      promotion_policy_ref: promotion_policy_ref,
      gepa_run_ref: result.run_ref,
      context_packet_ref: fetch(request, :context_packet_ref),
      route_decision_ref: fetch(request, :route_decision_ref),
      eval_refs: string_list(request, :eval_refs),
      cost_refs: string_list(request, :cost_refs),
      promotion_refs: list_ref(promotion_ref),
      rollback_refs: list_ref(rollback_ref),
      component_refs: Candidate.to_projection(candidate).component_refs
    }
    |> reject_nil_values()
  end

  defp objective_score_ref(%Candidate{} = candidate, objective_ref) do
    "objective-score://gepa/" <> hash_suffix(candidate.candidate_ref <> ":" <> objective_ref)
  end

  defp runtime_ref(request) do
    fetch(request, :run_ref) || fetch(request, :framework_run_ref) ||
      "run:gepa:mezzanine:" <>
        hash_suffix(Enum.join(candidate_source_refs_for_hash(request), "|"))
  end

  defp candidate_source_refs_for_hash(request) do
    case candidate_sources(request) do
      {:ok, refs} -> refs
      {:error, _failure} -> ["invalid"]
    end
  end

  defp examples(opts), do: Keyword.get(opts, :examples, [])

  defp candidate_sources(attrs) do
    refs = string_list(attrs, :candidate_source_refs)

    case refs do
      [_first | _rest] ->
        {:ok, refs}

      [] ->
        failure(
          "gepa.optimization.candidate_lineage_missing.v1",
          missing_refs(:candidate_source_refs)
        )
    end
  end

  defp required(attrs, field) do
    case fetch(attrs, field) do
      value when is_binary(value) and value != "" ->
        {:ok, value}

      _other ->
        failure("gepa.optimization.missing_required_ref.v1", missing_refs(field))
    end
  end

  defp reject_raw(input) do
    case forbidden_field(input) do
      nil ->
        :ok

      field ->
        failure("gepa.optimization.raw_payload_rejected.v1",
          safe_message: "GEPA optimization requests cannot carry raw payloads",
          evidence_refs: ["field://#{field_name(field)}"]
        )
    end
  end

  defp forbidden_field(input) when is_map(input) do
    Enum.find_value(input, fn {key, value} ->
      if key in @forbidden_raw_fields, do: key, else: forbidden_field(value)
    end)
  end

  defp forbidden_field(input) when is_list(input), do: Enum.find_value(input, &forbidden_field/1)
  defp forbidden_field(_input), do: nil

  defp first_ref(attrs, field) do
    attrs
    |> string_list(field)
    |> List.first()
  end

  defp string_list(attrs, field) do
    attrs
    |> Value.get(field, [])
    |> Value.string_list()
  end

  defp list_ref(value) when is_binary(value) and value != "", do: [value]
  defp list_ref(_value), do: []

  defp reject_nil_values(map) do
    map
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
  end

  defp fetch(attrs, field), do: Map.get(attrs, field) || Map.get(attrs, Atom.to_string(field))

  defp hash_suffix(value) do
    :crypto.hash(:sha256, value)
    |> Base.encode16(case: :lower)
    |> binary_part(0, 16)
  end

  defp missing_refs(field) do
    [
      safe_message: "GEPA optimization request is missing a required ref",
      evidence_refs: ["field://#{Atom.to_string(field)}"]
    ]
  end

  defp failure(reason_code, opts) do
    {:ok, failure} =
      Failure.new(%{
        owner: :gepa,
        reason_code: reason_code,
        safe_message: Keyword.fetch!(opts, :safe_message),
        evidence_refs: Keyword.get(opts, :evidence_refs, []),
        trace_ref: Keyword.get(opts, :trace_ref)
      })

    {:error, failure}
  end

  defp field_name(field) when is_atom(field), do: Atom.to_string(field)
  defp field_name(field), do: to_string(field)
end
