defmodule SelectoNorthwind.Catalog.ProductTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_tags" do
    belongs_to :product, SelectoNorthwind.Catalog.Product
    belongs_to :tag, SelectoNorthwind.Catalog.Tag

    timestamps()
  end

  @doc false
  def changeset(product_tag, attrs) do
    product_tag
    |> cast(attrs, [:product_id, :tag_id])
    |> validate_required([:product_id, :tag_id])
    |> unique_constraint([:product_id, :tag_id])
  end
end
