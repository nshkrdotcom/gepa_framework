defmodule GEPAFramework.GEPA.State do
  @moduledoc """
  Deterministic framework optimizer state.
  """

  alias GEPAFramework.Config

  @type t :: %__MODULE__{
          run_ref: String.t(),
          config: Config.t(),
          examples: [term()],
          iteration: non_neg_integer(),
          candidate_refs: [String.t()],
          trace_refs: [String.t()]
        }

  @enforce_keys [:run_ref, :config]
  defstruct [:run_ref, :config, examples: [], iteration: 0, candidate_refs: [], trace_refs: []]

  @spec new(Config.t(), [term()]) :: t()
  def new(%Config{} = config, examples) do
    %__MODULE__{
      run_ref: config.runtime_ref,
      config: config,
      examples: examples,
      trace_refs: config.tracing.trace_refs
    }
  end
end
