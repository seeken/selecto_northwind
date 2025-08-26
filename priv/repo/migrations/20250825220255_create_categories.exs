defmodule SelectoNorthwind.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :category_name, :string, null: false, size: 15
      add :description, :text
      add :picture, :binary

      timestamps()
    end

    create unique_index(:categories, [:category_name])
  end
end
