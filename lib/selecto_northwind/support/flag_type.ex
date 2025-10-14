defmodule SelectoNorthwind.Support.FlagType do
  @moduledoc """
  Schema for flag type registry - defines available dynamic attributes.

  Demonstrates Mode 5: Parameterized Flags join mode (EAV pattern).
  Flag types define what kinds of attributes can be attached to entities.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "flag_types" do
    field :name, :string
    field :label, :string
    field :entity_type, :string
    field :data_type, :string, default: "boolean"
    field :active, :boolean, default: true

    has_many :product_flags, SelectoNorthwind.Support.ProductFlag

    timestamps()
  end

  @doc false
  def changeset(flag_type, attrs) do
    flag_type
    |> cast(attrs, [:name, :label, :entity_type, :data_type, :active])
    |> validate_required([:name, :label, :entity_type])
    |> validate_inclusion(:data_type, ["boolean", "string", "integer", "decimal"])
    |> validate_inclusion(:entity_type, ["Product", "Supplier", "Order", "Customer"])
    |> unique_constraint([:entity_type, :name])
  end
end
