defmodule SelectoNorthwind.Sales.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:customer_id, :string, autogenerate: false}

  schema "customers" do
    field :company_name, :string
    field :contact_name, :string
    field :contact_title, :string
    field :address, :string
    field :city, :string
    field :region, :string
    field :postal_code, :string
    field :country, :string
    field :phone, :string
    field :fax, :string

    has_many :orders, SelectoNorthwind.Sales.Order, foreign_key: :customer_id
    many_to_many :customer_types, SelectoNorthwind.Sales.CustomerDemographic,
      join_through: SelectoNorthwind.Sales.CustomerCustomerDemo,
      join_keys: [customer_id: :customer_id, customer_type_id: :customer_type_id]

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:customer_id, :company_name, :contact_name, :contact_title, :address, :city, :region, :postal_code, :country, :phone, :fax])
    |> validate_required([:customer_id, :company_name])
    |> validate_length(:customer_id, is: 5)
    |> validate_length(:company_name, max: 40)
    |> validate_length(:contact_name, max: 30)
    |> validate_length(:contact_title, max: 30)
    |> validate_length(:address, max: 60)
    |> validate_length(:city, max: 15)
    |> validate_length(:region, max: 15)
    |> validate_length(:postal_code, max: 10)
    |> validate_length(:country, max: 15)
    |> validate_length(:phone, max: 24)
    |> validate_length(:fax, max: 24)
    |> unique_constraint(:customer_id, name: :customers_pkey)
  end
end
