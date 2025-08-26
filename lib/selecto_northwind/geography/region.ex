defmodule SelectoNorthwind.Geography.Region do
  use Ecto.Schema
  import Ecto.Changeset

  schema "regions" do
    field :region_description, :string

    has_many :territories, SelectoNorthwind.Geography.Territory

    timestamps()
  end

  @doc false
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:region_description])
    |> validate_required([:region_description])
    |> validate_length(:region_description, max: 60)
    |> unique_constraint(:region_description)
  end
end
