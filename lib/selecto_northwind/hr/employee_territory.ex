defmodule SelectoNorthwind.Hr.EmployeeTerritory do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "employee_territories" do
    belongs_to :employee, SelectoNorthwind.Hr.Employee, primary_key: true

    belongs_to :territory, SelectoNorthwind.Geography.Territory,
      primary_key: true,
      references: :territory_id,
      type: :string

    timestamps()
  end

  @doc false
  def changeset(employee_territory, attrs) do
    employee_territory
    |> cast(attrs, [:employee_id, :territory_id])
    |> validate_required([:employee_id, :territory_id])
    |> foreign_key_constraint(:employee_id)
    |> foreign_key_constraint(:territory_id)
  end
end
