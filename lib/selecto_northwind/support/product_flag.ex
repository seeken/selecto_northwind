defmodule SelectoNorthwind.Support.ProductFlag do
  @moduledoc """
  Schema for product flag values - stores actual attribute values.

  Demonstrates Mode 5: Parameterized Flags join mode (EAV pattern).
  Each record represents one attribute value for one product.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_flags" do
    field :value, :string

    belongs_to :product, SelectoNorthwind.Catalog.Product
    belongs_to :flag_type, SelectoNorthwind.Support.FlagType

    timestamps()
  end

  @doc false
  def changeset(product_flag, attrs) do
    product_flag
    |> cast(attrs, [:product_id, :flag_type_id, :value])
    |> validate_required([:product_id, :flag_type_id])
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:flag_type_id)
    |> unique_constraint([:product_id, :flag_type_id])
  end
end
