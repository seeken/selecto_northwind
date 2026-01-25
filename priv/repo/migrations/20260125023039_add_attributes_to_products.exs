defmodule SelectoNorthwind.Repo.Migrations.AddAttributesToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :attributes, :map, default: %{}
    end
  end
end
