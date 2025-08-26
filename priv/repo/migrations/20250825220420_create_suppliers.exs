defmodule SelectoNorthwind.Repo.Migrations.CreateSuppliers do
  use Ecto.Migration

  def change do
    create table(:suppliers) do
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
      add :homepage, :text

      timestamps()
    end

    create index(:suppliers, [:company_name])
    create index(:suppliers, [:postal_code])
  end
end
