defmodule ExScimEcto.QueryFilter do
  @moduledoc """
  Query filter adapter for building queries from SCIM filter ASTs.
  """

  @behaviour ExScim.QueryFilter.Adapter
  import Ecto.Query

  @impl true
  def apply_filter(query, nil), do: query

  def apply_filter(query, ast) do
    dynamic = build_dynamic(ast, [])
    from(q in query, where: ^dynamic)
  end

  def apply_filter(query, nil, _opts), do: query

  def apply_filter(query, ast, opts) do
    dynamic = build_dynamic(ast, opts)
    from(q in query, where: ^dynamic)
  end

  defp build_dynamic({:eq, field, value}, opts) do
    dynamic([u], field(u, ^resolve_field(field, opts)) == ^value)
  end

  defp build_dynamic({:ne, field, value}, opts) do
    dynamic([u], field(u, ^resolve_field(field, opts)) != ^value)
  end

  defp build_dynamic({:co, field, value}, opts) do
    dynamic([u], like(field(u, ^resolve_field(field, opts)), ^"%#{value}%"))
  end

  defp build_dynamic({:sw, field, value}, opts) do
    dynamic([u], like(field(u, ^resolve_field(field, opts)), ^"#{value}%"))
  end

  defp build_dynamic({:ew, field, value}, opts) do
    dynamic([u], like(field(u, ^resolve_field(field, opts)), ^"%#{value}"))
  end

  defp build_dynamic({:pr, field}, opts) do
    dynamic([u], not is_nil(field(u, ^resolve_field(field, opts))))
  end

  defp build_dynamic({:gt, field, value}, opts) do
    dynamic([u], field(u, ^resolve_field(field, opts)) > ^value)
  end

  defp build_dynamic({:ge, field, value}, opts) do
    dynamic([u], field(u, ^resolve_field(field, opts)) >= ^value)
  end

  defp build_dynamic({:lt, field, value}, opts) do
    dynamic([u], field(u, ^resolve_field(field, opts)) < ^value)
  end

  defp build_dynamic({:le, field, value}, opts) do
    dynamic([u], field(u, ^resolve_field(field, opts)) <= ^value)
  end

  defp build_dynamic({:and, left, right}, opts) do
    dynamic([u], ^build_dynamic(left, opts) and ^build_dynamic(right, opts))
  end

  defp build_dynamic({:or, left, right}, opts) do
    dynamic([u], ^build_dynamic(left, opts) or ^build_dynamic(right, opts))
  end

  defp resolve_field(scim_path, opts) do
    filter_mapping = Keyword.get(opts, :filter_mapping, %{})
    schema_fields = Keyword.get(opts, :schema_fields, nil)

    case Map.get(filter_mapping, scim_path) do
      nil ->
        underscore = Macro.underscore(scim_path)

        if String.contains?(underscore, ".") or String.contains?(underscore, "/") do
          raise ArgumentError,
                "Unsupported filter attribute \"#{scim_path}\". " <>
                  "Complex attribute paths require an explicit filter_mapping configuration."
        end

        atom =
          try do
            String.to_existing_atom(underscore)
          rescue
            ArgumentError ->
              raise ArgumentError, "Unknown filter attribute \"#{scim_path}\""
          end

        if schema_fields && atom not in schema_fields do
          raise ArgumentError, "Unknown filter attribute \"#{scim_path}\""
        end

        atom

      mapped_atom when is_atom(mapped_atom) ->
        mapped_atom
    end
  end
end
