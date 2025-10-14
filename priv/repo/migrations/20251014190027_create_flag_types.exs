defmodule SelectoNorthwind.Repo.Migrations.CreateFlagTypes do
  use Ecto.Migration

  def change do
    create table(:flag_types) do
      add :name, :string, null: false
      add :label, :string, null: false
      add :entity_type, :string, null: false
      add :data_type, :string, default: "boolean"
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:flag_types, [:entity_type, :name])
    create index(:flag_types, [:entity_type, :active])
  end
end
