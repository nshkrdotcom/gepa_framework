defmodule GEPAFramework.Value do
  @moduledoc false

  def to_map(value) when is_map(value), do: value
  def to_map(value) when is_list(value), do: Map.new(value)
  def to_map(_value), do: %{}

  def get(value, key, default \\ nil)

  def get(value, key, default) do
    map = to_map(value)
    string_key = if is_atom(key), do: Atom.to_string(key), else: key

    cond do
      Map.has_key?(map, key) -> Map.fetch!(map, key)
      Map.has_key?(map, string_key) -> Map.fetch!(map, string_key)
      true -> default
    end
  end

  def required(value, key) do
    case get(value, key, :missing) do
      :missing -> {:error, {:missing_key, key}}
      present -> {:ok, present}
    end
  end

  def list(value) when is_list(value), do: value
  def list(nil), do: []
  def list(value), do: [value]

  def string_list(value) do
    value
    |> list()
    |> Enum.filter(&is_binary/1)
  end
end
