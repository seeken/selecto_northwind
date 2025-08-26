defmodule SelectoNorthwind.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :product_name, :string, null: false, size: 40
      add :supplier_id, references(:suppliers, on_delete: :nilify_all)
      add :category_id, references(:categories, on_delete: :nilify_all)
      add :quantity_per_unit, :string, size: 20
      add :unit_price, :decimal, precision: 10, scale: 2
      add :units_in_stock, :integer
      add :units_on_order, :integer
      add :reorder_level, :integer
      add :discontinued, :boolean, null: false, default: false

      timestamps()
    end

    create index(:products, [:supplier_id])
    create index(:products, [:category_id])
    create index(:products, [:product_name])
    create index(:products, [:unit_price])
  end
end
