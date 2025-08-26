defmodule SelectoNorthwind.Repo.Migrations.CreateOrderDetails do
  use Ecto.Migration

  def change do
    create table(:order_details, primary_key: false) do
      add :order_id, references(:orders, on_delete: :delete_all), primary_key: true
      add :product_id, references(:products, on_delete: :delete_all), primary_key: true
      add :unit_price, :decimal, null: false, precision: 10, scale: 2
      add :quantity, :integer, null: false
      add :discount, :decimal, null: false, precision: 4, scale: 2

      timestamps()
    end

    create index(:order_details, [:order_id])
    create index(:order_details, [:product_id])
  end
end
