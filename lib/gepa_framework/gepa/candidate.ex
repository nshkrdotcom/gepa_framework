defmodule GEPAFramework.GEPA.Candidate do
  @moduledoc """
  Ref-only candidate boundary for compact GEPA component maps.
  """

  alias GEPAFramework.{Persistence, Value}

  @type t :: %__MODULE__{
          candidate_ref: String.t(),
          components: map(),
          lineage_refs: [String.t()],
          diff_refs: [String.t()],
          parent_refs: [String.t()],
          merge_refs: [String.t()],
          objective_refs: [String.t()],
          rejection_reasons: [String.t()],
          checkpoint: Persistence.t(),
          trace_refs: [String.t()]
        }

  @enforce_keys [:candidate_ref, :components, :checkpoint]
  defstruct [
    :candidate_ref,
    components: %{},
    lineage_refs: [],
    diff_refs: [],
    parent_refs: [],
    merge_refs: [],
    objective_refs: [],
    rejection_reasons: [],
    checkpoint: Persistence.default(),
    trace_refs: []
  ]

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

  @spec wrap(map() | keyword() | t()) :: {:ok, t()} | {:error, term()}
  def wrap(%__MODULE__{} = candidate), do: {:ok, candidate}

  def wrap(input) do
    with :ok <- reject_raw_fields(input),
         {:ok, candidate_ref} when is_binary(candidate_ref) <-
           Value.required(input, :candidate_ref),
         components when is_map(components) <- Value.get(input, :components, %{}),
         :ok <- validate_component_refs(components),
         {:ok, checkpoint} <- Persistence.from_map(Value.get(input, :checkpoint, %{})) do
      {:ok,
       %__MODULE__{
         candidate_ref: candidate_ref,
         components: components,
         lineage_refs: Value.string_list(Value.get(input, :lineage_refs, [])),
         diff_refs: Value.string_list(Value.get(input, :diff_refs, [])),
         parent_refs: Value.string_list(Value.get(input, :parent_refs, [])),
         merge_refs: Value.string_list(Value.get(input, :merge_refs, [])),
         objective_refs: Value.string_list(Value.get(input, :objective_refs, [])),
         rejection_reasons: Value.string_list(Value.get(input, :rejection_reasons, [])),
         checkpoint: checkpoint,
         trace_refs: Value.string_list(Value.get(input, :trace_refs, []))
       }}
    else
      {:ok, _invalid} -> {:error, {:invalid_key, :candidate_ref}}
      value when not is_tuple(value) -> {:error, :invalid_component_map}
      error -> error
    end
  end

  @spec to_projection(t()) :: map()
  def to_projection(%__MODULE__{} = candidate) do
    %{
      candidate_ref: candidate.candidate_ref,
      component_refs: component_refs(candidate.components),
      lineage_refs: candidate.lineage_refs,
      diff_refs: candidate.diff_refs,
      parent_refs: candidate.parent_refs,
      merge_refs: candidate.merge_refs,
      objective_refs: candidate.objective_refs,
      rejection_reasons: candidate.rejection_reasons,
      checkpoint: Persistence.to_projection(candidate.checkpoint),
      trace_refs: candidate.trace_refs
    }
  end

  defp reject_raw_fields(input) do
    case forbidden_field(input) do
      nil -> :ok
      field -> {:error, {:forbidden_raw_field, field}}
    end
  end

  defp forbidden_field(%_struct{} = input) do
    input
    |> Map.from_struct()
    |> forbidden_field()
  end

  defp forbidden_field(input) when is_map(input) do
    Enum.find_value(input, fn {key, value} ->
      if key in @forbidden_raw_fields, do: key, else: forbidden_field(value)
    end)
  end

  defp forbidden_field(input) when is_list(input) do
    Enum.find_value(input, &forbidden_field/1)
  end

  defp forbidden_field(_input), do: nil

  defp validate_component_refs(components) when map_size(components) > 0 do
    components
    |> Map.values()
    |> Enum.all?(
      &(is_binary(Value.get(&1, :component_ref)) and is_binary(Value.get(&1, :content_ref)))
    )
    |> case do
      true -> :ok
      false -> {:error, :component_refs_required}
    end
  end

  defp validate_component_refs(_components), do: {:error, :component_refs_required}

  defp component_refs(components) do
    components
    |> Map.values()
    |> Enum.map(&Value.get(&1, :component_ref))
    |> Enum.filter(&is_binary/1)
    |> Enum.sort()
  end
end
