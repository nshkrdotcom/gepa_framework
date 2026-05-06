defmodule GEPAFramework.Task do
  @moduledoc """
  Ref-only task descriptor consumed by a GEPA runtime.
  """

  alias GEPAFramework.Value

  @type t :: %__MODULE__{
          task_ref: String.t(),
          dataset_ref: String.t() | nil,
          objective_refs: [String.t()]
        }

  @enforce_keys [:task_ref]
  defstruct [:task_ref, :dataset_ref, objective_refs: []]

  @spec from_map(map() | keyword() | t()) :: {:ok, t()} | {:error, term()}
  def from_map(%__MODULE__{} = task), do: {:ok, task}

  def from_map(input) do
    case Value.required(input, :task_ref) do
      {:ok, task_ref} when is_binary(task_ref) ->
        {:ok,
         %__MODULE__{
           task_ref: task_ref,
           dataset_ref: Value.get(input, :dataset_ref),
           objective_refs: Value.string_list(Value.get(input, :objective_refs, []))
         }}

      {:ok, _invalid} ->
        {:error, {:invalid_key, :task_ref}}

      error ->
        error
    end
  end
end
