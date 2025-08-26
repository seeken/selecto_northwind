defmodule SelectoNorthwind.Sales.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :order_date, :date
    field :required_date, :date
    field :shipped_date, :date
    field :freight, :decimal
    field :ship_name, :string
    field :ship_address, :string
    field :ship_city, :string
    field :ship_region, :string
    field :ship_postal_code, :string
    field :ship_country, :string

    belongs_to :customer, SelectoNorthwind.Sales.Customer,
      foreign_key: :customer_id, references: :customer_id, type: :string
    belongs_to :employee, SelectoNorthwind.Hr.Employee
    belongs_to :shipper, SelectoNorthwind.Sales.Shipper, foreign_key: :ship_via

    has_many :order_details, SelectoNorthwind.Sales.OrderDetail

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:customer_id, :employee_id, :order_date, :required_date, :shipped_date, :ship_via, :freight, :ship_name, :ship_address, :ship_city, :ship_region, :ship_postal_code, :ship_country])
    |> validate_length(:ship_name, max: 40)
    |> validate_length(:ship_address, max: 60)
    |> validate_length(:ship_city, max: 15)
    |> validate_length(:ship_region, max: 15)
    |> validate_length(:ship_postal_code, max: 10)
    |> validate_length(:ship_country, max: 15)
    |> validate_number(:freight, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:employee_id)
    |> foreign_key_constraint(:ship_via)
  end
end
