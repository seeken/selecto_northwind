defmodule SelectoNorthwind.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :customer_id,
          references(:customers, column: :customer_id, type: :string, on_delete: :nilify_all)

      add :employee_id, references(:employees, on_delete: :nilify_all)
      add :order_date, :date
      add :required_date, :date
      add :shipped_date, :date
      add :ship_via, references(:shippers, on_delete: :nilify_all)
      add :freight, :decimal, precision: 10, scale: 2
      add :ship_name, :string, size: 40
      add :ship_address, :string, size: 60
      add :ship_city, :string, size: 15
      add :ship_region, :string, size: 15
      add :ship_postal_code, :string, size: 10
      add :ship_country, :string, size: 15

      timestamps()
    end

    create index(:orders, [:customer_id])
    create index(:orders, [:employee_id])
    create index(:orders, [:order_date])
    create index(:orders, [:required_date])
    create index(:orders, [:shipped_date])
    create index(:orders, [:ship_via])
    create index(:orders, [:ship_postal_code])
  end
end
