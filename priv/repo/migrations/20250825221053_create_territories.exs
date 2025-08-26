defmodule SelectoNorthwind.Repo.Migrations.CreateTerritories do
  use Ecto.Migration

  def change do
    create table(:territories, primary_key: false) do
      add :territory_id, :string, primary_key: true, size: 20
      add :territory_description, :string, null: false, size: 60
      add :region_id, references(:regions, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:territories, [:region_id])
  end
end
