defmodule SelectoNorthwind.Catalog.Supplier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "suppliers" do
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
    field :homepage, :string

    has_many :products, SelectoNorthwind.Catalog.Product

    timestamps()
  end

  @doc false
  def changeset(supplier, attrs) do
    supplier
    |> cast(attrs, [
      :company_name,
      :contact_name,
      :contact_title,
      :address,
      :city,
      :region,
      :postal_code,
      :country,
      :phone,
      :fax,
      :homepage
    ])
    |> validate_required([:company_name])
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
  end
end
