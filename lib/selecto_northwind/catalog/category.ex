defmodule SelectoNorthwind.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :category_name, :string
    field :description, :string
    field :picture, :binary

    has_many :products, SelectoNorthwind.Catalog.Product

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:category_name, :description, :picture])
    |> validate_required([:category_name])
    |> validate_length(:category_name, max: 15)
    |> unique_constraint(:category_name)
  end
end
