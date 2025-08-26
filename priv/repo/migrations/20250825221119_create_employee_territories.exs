defmodule SelectoNorthwind.Repo.Migrations.CreateEmployeeTerritories do
  use Ecto.Migration

  def change do
    create table(:employee_territories, primary_key: false) do
      add :employee_id, references(:employees, on_delete: :delete_all), primary_key: true
      add :territory_id, references(:territories, column: :territory_id, type: :string, on_delete: :delete_all), primary_key: true

      timestamps()
    end

    create index(:employee_territories, [:employee_id])
    create index(:employee_territories, [:territory_id])
  end
end
