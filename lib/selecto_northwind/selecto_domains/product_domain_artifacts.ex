defmodule SelectoNorthwind.SelectoDomains.ProductDomainArtifacts do
  @moduledoc """
  Trusted Selecto domain artifact provider for SelectoNorthwind.SelectoDomains.ProductDomain.

  Register `inspection_artifact/0` with `SelectoStudio.DomainArtifacts` when
  this host app wants Studio to preload this domain. The provider uses core
  `Selecto.Domain` APIs directly so the domain itself does not depend on
  SelectoStudio.
  """

  @domain_module SelectoNorthwind.SelectoDomains.ProductDomain
  @format_version 1
  @inspection_format_version 1

  @spec inspection_artifact() :: {:ok, map()} | {:error, term()}
  def inspection_artifact do
    with {:ok, normalized, _normalize_diagnostics} <-
           Selecto.Domain.normalize(@domain_module.domain()),
         {:ok, inspection, diagnostics} <- Selecto.Domain.describe(normalized) do
      domain = Map.get(normalized, :domain) || Map.get(normalized, "domain") || normalized

      {:ok,
       %{
         "format" => "selecto.domain_inspection",
         "format_version" => @inspection_format_version,
         "source" => %{
           "artifact_format" => "selecto.normalized_domain",
           "artifact_format_version" => @format_version,
           "domain_module" => inspect(@domain_module),
           "schema_version" => json_value(Map.get(normalized, :schema_version)),
           "name" => json_value(map_value(domain, :name))
         },
         "inspection" => json_value(inspection),
         "diagnostics" => json_value(diagnostics),
         "links" => %{}
       }}
    end
  end

  defp json_value(%_struct{} = value) do
    value
    |> Map.from_struct()
    |> json_value()
  end

  defp json_value(value) when is_map(value) do
    Map.new(value, fn {key, item} -> {json_key(key), json_value(item)} end)
  end

  defp json_value(value) when is_list(value), do: Enum.map(value, &json_value/1)
  defp json_value(value) when is_tuple(value), do: value |> Tuple.to_list() |> json_value()

  defp json_value(value) when is_function(value) do
    function_info =
      value
      |> Function.info()
      |> Map.new()
      |> Map.take([:module, :name, :arity, :type])

    %{
      "$selecto_export" => "function",
      "inspect" => inspect(value),
      "function" => json_value(function_info)
    }
  end

  defp json_value(value) when is_pid(value) or is_port(value) or is_reference(value) do
    %{
      "$selecto_export" => "term",
      "type" => value |> term_type() |> Atom.to_string(),
      "inspect" => inspect(value)
    }
  end

  defp json_value(value) when is_atom(value), do: atom_value(value)
  defp json_value(value), do: value

  defp atom_value(nil), do: nil
  defp atom_value(true), do: true
  defp atom_value(false), do: false
  defp atom_value(value), do: Atom.to_string(value)

  defp json_key(value) when is_atom(value), do: Atom.to_string(value)
  defp json_key(value) when is_binary(value), do: value
  defp json_key(value), do: inspect(value)

  defp term_type(value) when is_pid(value), do: :pid
  defp term_type(value) when is_port(value), do: :port
  defp term_type(value) when is_reference(value), do: :reference

  defp map_value(map, key, default \\ nil)

  defp map_value(map, key, default) when is_map(map) and is_atom(key) do
    string_key = Atom.to_string(key)

    cond do
      Map.has_key?(map, key) -> Map.get(map, key)
      Map.has_key?(map, string_key) -> Map.get(map, string_key)
      true -> default
    end
  end

  defp map_value(_map, _key, default), do: default
end
