defmodule SelectoNorthwind.Repo.Migrations.CreateShippers do
  use Ecto.Migration

  def change do
    create table(:shippers) do
      add :company_name, :string, null: false, size: 40
      add :phone, :string, size: 24

      timestamps()
    end

    create index(:shippers, [:company_name])
  end
end
