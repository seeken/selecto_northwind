defmodule SelectoNorthwind.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def change do
    create table(:regions) do
      add :region_description, :string, null: false, size: 60

      timestamps()
    end

    create unique_index(:regions, [:region_description])
  end
end
