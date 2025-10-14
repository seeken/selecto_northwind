defmodule SelectoNorthwind.Repo.Migrations.CreateProductFlags do
  use Ecto.Migration

  def change do
    create table(:product_flags) do
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :flag_type_id, references(:flag_types, on_delete: :delete_all), null: false
      add :value, :text

      timestamps()
    end

    create unique_index(:product_flags, [:product_id, :flag_type_id])
    create index(:product_flags, [:flag_type_id])
  end
end
