defmodule SelectoNorthwind.Sales.CustomerCustomerDemo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "customer_customer_demo" do
    belongs_to :customer, SelectoNorthwind.Sales.Customer,
      primary_key: true, references: :customer_id, type: :string
    belongs_to :customer_type, SelectoNorthwind.Sales.CustomerDemographic,
      primary_key: true, foreign_key: :customer_type_id, references: :customer_type_id, type: :string

    timestamps()
  end

  @doc false
  def changeset(customer_customer_demo, attrs) do
    customer_customer_demo
    |> cast(attrs, [:customer_id, :customer_type_id])
    |> validate_required([:customer_id, :customer_type_id])
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:customer_type_id)
  end
end
