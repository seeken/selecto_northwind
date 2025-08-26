defmodule SelectoNorthwind.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers, primary_key: false) do
      add :customer_id, :string, primary_key: true, size: 5
      add :company_name, :string, null: false, size: 40
      add :contact_name, :string, size: 30
      add :contact_title, :string, size: 30
      add :address, :string, size: 60
      add :city, :string, size: 15
      add :region, :string, size: 15
      add :postal_code, :string, size: 10
      add :country, :string, size: 15
      add :phone, :string, size: 24
      add :fax, :string, size: 24

      timestamps()
    end

    create index(:customers, [:company_name])
    create index(:customers, [:city])
    create index(:customers, [:region])
    create index(:customers, [:postal_code])
  end
end
