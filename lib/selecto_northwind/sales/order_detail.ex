defmodule SelectoNorthwind.Sales.OrderDetail do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "order_details" do
    field :unit_price, :decimal
    field :quantity, :integer
    field :discount, :decimal

    belongs_to :order, SelectoNorthwind.Sales.Order, primary_key: true
    belongs_to :product, SelectoNorthwind.Catalog.Product, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(order_detail, attrs) do
    order_detail
    |> cast(attrs, [:order_id, :product_id, :unit_price, :quantity, :discount])
    |> validate_required([:order_id, :product_id, :unit_price, :quantity, :discount])
    |> validate_number(:unit_price, greater_than_or_equal_to: 0)
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:discount, greater_than_or_equal_to: 0, less_than: 1)
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:product_id)
  end

  def total_price(%SelectoNorthwind.Sales.OrderDetail{unit_price: unit_price, quantity: quantity, discount: discount}) do
    line_total = Decimal.mult(unit_price, quantity)
    discount_amount = Decimal.mult(line_total, discount)
    Decimal.sub(line_total, discount_amount)
  end
end
