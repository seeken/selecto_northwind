defmodule SelectoNorthwind.Geography.Territory do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:territory_id, :string, autogenerate: false}

  schema "territories" do
    field :territory_description, :string

    belongs_to :region, SelectoNorthwind.Geography.Region

    many_to_many :employees, SelectoNorthwind.Hr.Employee,
      join_through: SelectoNorthwind.Hr.EmployeeTerritory,
      join_keys: [territory_id: :territory_id, employee_id: :id]

    timestamps()
  end

  @doc false
  def changeset(territory, attrs) do
    territory
    |> cast(attrs, [:territory_id, :territory_description, :region_id])
    |> validate_required([:territory_id, :territory_description, :region_id])
    |> validate_length(:territory_id, max: 20)
    |> validate_length(:territory_description, max: 60)
    |> unique_constraint(:territory_id, name: :territories_pkey)
    |> foreign_key_constraint(:region_id)
  end
end
