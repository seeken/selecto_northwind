defmodule SelectoNorthwind.Sales.CustomerDemographic do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:customer_type_id, :string, autogenerate: false}

  schema "customer_demographics" do
    field :customer_desc, :string

    many_to_many :customers, SelectoNorthwind.Sales.Customer,
      join_through: SelectoNorthwind.Sales.CustomerCustomerDemo,
      join_keys: [customer_type_id: :customer_type_id, customer_id: :customer_id]

    timestamps()
  end

  @doc false
  def changeset(customer_demographic, attrs) do
    customer_demographic
    |> cast(attrs, [:customer_type_id, :customer_desc])
    |> validate_required([:customer_type_id])
    |> validate_length(:customer_type_id, max: 5)
    |> unique_constraint(:customer_type_id, name: :customer_demographics_pkey)
  end
end
