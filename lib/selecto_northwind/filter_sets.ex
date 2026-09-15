defmodule SelectoNorthwind.FilterSets do
  @moduledoc """
  Context for managing saved filter sets.
  Implements the SelectoComponents.FilterSetsBehaviour.
  """

  @behaviour SelectoComponents.FilterSetsBehaviour

  import Ecto.Query, warn: false
  alias SelectoNorthwind.Repo
  alias SelectoNorthwind.FilterSets.FilterSet

  @impl true
  def list_personal_filter_sets(user_id, domain) do
    domain = scoped_domain(domain)

    FilterSet
    |> where([f], f.user_id == ^user_id and f.domain == ^domain)
    |> where([f], f.is_system == false)
    |> order_by([f], desc: f.is_default, asc: f.name)
    |> Repo.all()
  end

  @impl true
  def list_shared_filter_sets(_user_id, domain) do
    domain = scoped_domain(domain)

    FilterSet
    |> where([f], f.is_shared == true and f.domain == ^domain)
    |> where([f], f.is_system == false)
    |> order_by([f], asc: f.name)
    |> Repo.all()
  end

  @impl true
  def list_system_filter_sets(domain) do
    domain = scoped_domain(domain)

    FilterSet
    |> where([f], f.is_system == true and f.domain == ^domain)
    |> order_by([f], asc: f.name)
    |> Repo.all()
  end

  @impl true
  def get_filter_set(id, user_id) do
    case Repo.get(FilterSet, id) do
      nil ->
        {:error, :not_found}

      %{is_system: true} = filter_set ->
        {:ok, filter_set}

      %{is_shared: true} = filter_set ->
        {:ok, filter_set}

      %{user_id: ^user_id} = filter_set ->
        {:ok, filter_set}

      _ ->
        {:error, :unauthorized}
    end
  end

  @impl true
  def create_filter_set(attrs) do
    # If setting as default, unset other defaults for this user/domain
    attrs = scope_attrs_domain(attrs)
    attrs = maybe_unset_other_defaults(attrs)

    %FilterSet{}
    |> FilterSet.changeset(attrs)
    |> Repo.insert()
  end

  @impl true
  def update_filter_set(id, attrs, user_id) do
    with {:ok, filter_set} <- get_filter_set(id, user_id),
         false <- filter_set.is_system do
      attrs = maybe_unset_other_defaults(attrs, filter_set)

      filter_set
      |> FilterSet.changeset(attrs)
      |> Repo.update()
    else
      true -> {:error, :cannot_modify_system}
      error -> error
    end
  end

  @impl true
  def delete_filter_set(id, user_id) do
    with {:ok, filter_set} <- get_filter_set(id, user_id),
         false <- filter_set.is_system,
         true <- filter_set.user_id == user_id do
      Repo.delete(filter_set)
    else
      true -> {:error, :cannot_delete_system}
      false -> {:error, :unauthorized}
      error -> error
    end
  end

  @impl true
  def set_default_filter_set(id, user_id) do
    with {:ok, filter_set} <- get_filter_set(id, user_id) do
      # Unset any existing default
      from(f in FilterSet,
        where: f.user_id == ^user_id and f.domain == ^filter_set.domain and f.is_default == true
      )
      |> Repo.update_all(set: [is_default: false])

      # Set new default
      filter_set
      |> FilterSet.changeset(%{is_default: true})
      |> Repo.update()
    end
  end

  @impl true
  def get_default_filter_set(user_id, domain) do
    domain = scoped_domain(domain)

    FilterSet
    |> where([f], f.user_id == ^user_id and f.domain == ^domain and f.is_default == true)
    |> Repo.one()
  end

  @impl true
  def increment_usage_count(id) do
    from(f in FilterSet, where: f.id == ^id)
    |> Repo.update_all(inc: [usage_count: 1])

    :ok
  end

  @impl true
  def duplicate_filter_set(id, new_name, user_id) do
    with {:ok, source} <- get_filter_set(id, user_id) do
      create_filter_set(%{
        name: new_name,
        description: source.description,
        domain: source.domain,
        filters: source.filters,
        user_id: user_id,
        is_default: false,
        is_shared: false,
        is_system: false
      })
    end
  end

  # Private functions

  defp scoped_domain(domain) do
    case domain do
      %{} = domain_map ->
        raw_domain =
          Map.get(domain_map, :domain) ||
            Map.get(domain_map, "domain") ||
            Map.get(domain_map, :path) ||
            Map.get(domain_map, "path") ||
            "default"

        tenant_context =
          Map.get(domain_map, :tenant) ||
            Map.get(domain_map, "tenant") ||
            %{tenant_id: Map.get(domain_map, :tenant_id) || Map.get(domain_map, "tenant_id")}

        if Code.ensure_loaded?(SelectoComponents.Tenant) do
          SelectoComponents.Tenant.scoped_context(raw_domain, tenant_context)
        else
          raw_domain
        end

      _ ->
        domain
    end
  end

  defp scope_attrs_domain(attrs) when is_map(attrs) do
    domain = Map.get(attrs, :domain) || Map.get(attrs, "domain")

    case domain do
      nil -> attrs
      value -> Map.put(attrs, :domain, scoped_domain(value))
    end
  end

  defp scope_attrs_domain(attrs), do: attrs

  defp maybe_unset_other_defaults(attrs, existing \\ nil) do
    if should_unset_defaults?(attrs, existing) do
      user_id = attrs[:user_id] || attrs["user_id"] || existing.user_id
      domain = attrs[:domain] || attrs["domain"] || existing.domain

      unset_defaults(user_id, domain)
    end

    attrs
  end

  defp should_unset_defaults?(attrs, existing) do
    is_default = attrs[:is_default] || attrs["is_default"] || false
    is_default && (is_nil(existing) || !existing.is_default)
  end

  defp unset_defaults(user_id, domain) when is_nil(user_id) or is_nil(domain), do: :ok

  defp unset_defaults(user_id, domain) do
    from(f in FilterSet,
      where: f.user_id == ^user_id and f.domain == ^domain and f.is_default == true
    )
    |> Repo.update_all(set: [is_default: false])

    :ok
  end
end
