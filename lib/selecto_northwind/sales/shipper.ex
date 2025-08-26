defmodule SelectoNorthwind.Sales.Shipper do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shippers" do
    field :company_name, :string
    field :phone, :string

    has_many :orders, SelectoNorthwind.Sales.Order, foreign_key: :ship_via

    timestamps()
  end

  @doc false
  def changeset(shipper, attrs) do
    shipper
    |> cast(attrs, [:company_name, :phone])
    |> validate_required([:company_name])
    |> validate_length(:company_name, max: 40)
    |> validate_length(:phone, max: 24)
  end
end
