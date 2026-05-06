defmodule GEPAFramework.Tracing do
  @moduledoc """
  Trace-reference container for framework runs.
  """

  alias GEPAFramework.Value

  @type t :: %__MODULE__{trace_refs: [String.t()]}

  defstruct trace_refs: []

  @spec from_map(map() | keyword() | t() | nil) :: t()
  def from_map(nil), do: %__MODULE__{}
  def from_map(%__MODULE__{} = tracing), do: tracing

  def from_map(input) do
    %__MODULE__{trace_refs: Value.string_list(Value.get(input, :trace_refs, []))}
  end
end
