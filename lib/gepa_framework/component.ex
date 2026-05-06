defmodule GEPAFramework.Component do
  @moduledoc """
  Compact component descriptor for optimizer candidates.
  """

  alias GEPAFramework.Value

  @type kind :: :component | :instruction | :retrieval | :tool_policy | :verifier | :context

  @type t :: %__MODULE__{
          component_ref: String.t(),
          kind: kind(),
          content_ref: String.t(),
          metadata_refs: [String.t()]
        }

  @enforce_keys [:component_ref, :content_ref]
  defstruct [:component_ref, :content_ref, kind: :component, metadata_refs: []]

  @kind_aliases %{
    "component" => :component,
    "instruction" => :instruction,
    "retrieval" => :retrieval,
    "tool_policy" => :tool_policy,
    "verifier" => :verifier,
    "context" => :context
  }

  @allowed_kinds Map.values(@kind_aliases)

  @spec from_map(map() | keyword() | t()) :: {:ok, t()} | {:error, term()}
  def from_map(%__MODULE__{} = component), do: {:ok, component}

  def from_map(input) do
    with {:ok, component_ref} when is_binary(component_ref) <-
           Value.required(input, :component_ref),
         {:ok, content_ref} when is_binary(content_ref) <- Value.required(input, :content_ref),
         {:ok, kind} <- normalize_kind(Value.get(input, :kind, :component)) do
      {:ok,
       %__MODULE__{
         component_ref: component_ref,
         content_ref: content_ref,
         kind: kind,
         metadata_refs: Value.string_list(Value.get(input, :metadata_refs, []))
       }}
    else
      {:ok, _invalid} -> {:error, :invalid_component_descriptor}
      error -> error
    end
  end

  @spec to_candidate_entry(t()) :: {String.t(), map()}
  def to_candidate_entry(%__MODULE__{} = component) do
    {component.component_ref,
     %{
       component_ref: component.component_ref,
       content_ref: component.content_ref,
       metadata_refs: component.metadata_refs
     }}
  end

  defp normalize_kind(kind) when is_atom(kind) do
    if kind in @allowed_kinds, do: {:ok, kind}, else: {:error, {:invalid_component_kind, kind}}
  end

  defp normalize_kind(kind) when is_binary(kind) do
    case Map.fetch(@kind_aliases, kind) do
      {:ok, value} -> {:ok, value}
      :error -> {:error, {:invalid_component_kind, kind}}
    end
  end

  defp normalize_kind(kind), do: {:error, {:invalid_component_kind, kind}}
end
