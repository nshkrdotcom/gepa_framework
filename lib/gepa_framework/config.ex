defmodule GEPAFramework.Config do
  @moduledoc """
  Typed GEPA framework config compiled from map or keyword input.
  """

  alias GEPAFramework.{Component, Persistence, Task, Tracing, Value}

  @type descriptor :: %{
          optional(:adapter_ref) => String.t(),
          optional(:type) => atom(),
          optional(:mode) => atom()
        }

  @type t :: %__MODULE__{
          runtime_ref: String.t(),
          task: Task.t(),
          components: [Component.t()],
          adapters: [descriptor()],
          data_loader: map(),
          evaluator: map(),
          proposer: map(),
          merge: map(),
          persistence: Persistence.t(),
          tracing: Tracing.t()
        }

  @enforce_keys [:runtime_ref, :task, :components, :persistence, :tracing]
  defstruct [
    :runtime_ref,
    :task,
    components: [],
    adapters: [],
    data_loader: %{},
    evaluator: %{},
    proposer: %{},
    merge: %{},
    persistence: Persistence.default(),
    tracing: %Tracing{}
  ]

  @spec compile(map() | keyword() | t()) :: {:ok, t()} | {:error, term()}
  def compile(%__MODULE__{} = config), do: {:ok, config}

  def compile(input) do
    with {:ok, runtime_ref} when is_binary(runtime_ref) <- Value.required(input, :runtime_ref),
         {:ok, task} <- Task.from_map(Value.get(input, :task, %{})),
         {:ok, components} <- compile_components(Value.get(input, :components, [])),
         {:ok, persistence} <- Persistence.from_map(Value.get(input, :persistence, %{})) do
      {:ok,
       %__MODULE__{
         runtime_ref: runtime_ref,
         task: task,
         components: components,
         adapters: compile_descriptors(Value.get(input, :adapters, [])),
         data_loader: compile_descriptor(Value.get(input, :data_loader, %{})),
         evaluator: compile_descriptor(Value.get(input, :evaluator, %{})),
         proposer: compile_descriptor(Value.get(input, :proposer, %{})),
         merge: compile_descriptor(Value.get(input, :merge, %{strategy: :disabled})),
         persistence: persistence,
         tracing: Tracing.from_map(Value.get(input, :tracing, %{}))
       }}
    else
      {:ok, _invalid} -> {:error, {:invalid_key, :runtime_ref}}
      error -> error
    end
  end

  @spec to_runtime_spec(t()) :: map()
  def to_runtime_spec(%__MODULE__{} = config) do
    %{
      runtime_ref: config.runtime_ref,
      task_ref: config.task.task_ref,
      component_refs: Enum.map(config.components, & &1.component_ref),
      adapter_refs: descriptor_refs(config.adapters),
      data_loader: config.data_loader,
      evaluator: config.evaluator,
      proposer: config.proposer,
      merge: config.merge,
      checkpoint: Persistence.to_projection(config.persistence),
      trace_refs: config.tracing.trace_refs
    }
  end

  defp compile_components(components) do
    components
    |> Value.list()
    |> Enum.reduce_while({:ok, []}, fn component, {:ok, acc} ->
      case Component.from_map(component) do
        {:ok, compiled} -> {:cont, {:ok, [compiled | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, []} -> {:error, :components_required}
      {:ok, components} -> {:ok, Enum.reverse(components)}
      error -> error
    end
  end

  defp compile_descriptors(descriptors) do
    descriptors
    |> Value.list()
    |> Enum.map(&compile_descriptor/1)
  end

  defp compile_descriptor(input) do
    input
    |> Value.to_map()
    |> Enum.into(%{})
  end

  defp descriptor_refs(descriptors) do
    descriptors
    |> Enum.map(&Value.get(&1, :adapter_ref))
    |> Enum.filter(&is_binary/1)
  end
end
