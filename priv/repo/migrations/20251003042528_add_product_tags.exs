defmodule SelectoNorthwind.Repo.Migrations.AddProductTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string, null: false
      add :description, :text

      timestamps()
    end

    create unique_index(:tags, [:name])

    create table(:product_tags) do
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:product_tags, [:product_id])
    create index(:product_tags, [:tag_id])
    create unique_index(:product_tags, [:product_id, :tag_id])
  end
end
