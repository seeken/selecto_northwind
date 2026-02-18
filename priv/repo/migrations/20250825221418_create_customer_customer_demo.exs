defmodule SelectoNorthwind.Repo.Migrations.CreateCustomerCustomerDemo do
  use Ecto.Migration

  def change do
    create table(:customer_customer_demo, primary_key: false) do
      add :customer_id,
          references(:customers, column: :customer_id, type: :string, on_delete: :delete_all),
          primary_key: true

      add :customer_type_id,
          references(:customer_demographics,
            column: :customer_type_id,
            type: :string,
            on_delete: :delete_all
          ), primary_key: true

      timestamps()
    end

    create index(:customer_customer_demo, [:customer_id])
    create index(:customer_customer_demo, [:customer_type_id])
  end
end
