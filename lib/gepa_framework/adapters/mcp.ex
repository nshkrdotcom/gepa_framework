defmodule GEPAFramework.Adapters.MCP do
  @moduledoc """
  Descriptor for MCP-shaped framework adapters.
  """

  @spec descriptor(String.t(), [String.t()]) :: map()
  def descriptor(adapter_ref, tool_refs) when is_binary(adapter_ref) and is_list(tool_refs) do
    %{adapter_ref: adapter_ref, type: :mcp, tool_refs: tool_refs}
  end
end
