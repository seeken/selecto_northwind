defmodule SelectoNorthwind.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :product_name, :string
    field :quantity_per_unit, :string
    field :unit_price, :decimal
    field :units_in_stock, :integer
    field :units_on_order, :integer
    field :reorder_level, :integer
    field :discontinued, :boolean, default: false
    field :attributes, :map, default: %{}

    belongs_to :supplier, SelectoNorthwind.Catalog.Supplier
    belongs_to :category, SelectoNorthwind.Catalog.Category

    has_many :order_details, SelectoNorthwind.Sales.OrderDetail

    many_to_many :tags, SelectoNorthwind.Catalog.Tag,
      join_through: "product_tags",
      on_replace: :delete

    has_many :product_flags, SelectoNorthwind.Support.ProductFlag

    many_to_many :flag_types, SelectoNorthwind.Support.FlagType,
      join_through: SelectoNorthwind.Support.ProductFlag

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :product_name,
      :supplier_id,
      :category_id,
      :quantity_per_unit,
      :unit_price,
      :units_in_stock,
      :units_on_order,
      :reorder_level,
      :discontinued,
      :attributes
    ])
    |> validate_required([:product_name])
    |> validate_length(:product_name, max: 40)
    |> validate_length(:quantity_per_unit, max: 20)
    |> validate_number(:unit_price, greater_than_or_equal_to: 0)
    |> validate_number(:units_in_stock, greater_than_or_equal_to: 0)
    |> validate_number(:units_on_order, greater_than_or_equal_to: 0)
    |> validate_number(:reorder_level, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:supplier_id)
    |> foreign_key_constraint(:category_id)
  end
end
