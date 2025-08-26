defmodule SelectoNorthwind.Repo.Migrations.CreateUsStates do
  use Ecto.Migration

  def change do
    create table(:us_states) do
      add :state_name, :string, size: 100
      add :state_abbr, :string, size: 2
      add :state_region, :string, size: 50

      timestamps()
    end

    create unique_index(:us_states, [:state_abbr])
    create index(:us_states, [:state_name])
    create index(:us_states, [:state_region])
  end
end
