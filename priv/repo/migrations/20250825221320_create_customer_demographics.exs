defmodule SelectoNorthwind.Repo.Migrations.CreateCustomerDemographics do
  use Ecto.Migration

  def change do
    create table(:customer_demographics, primary_key: false) do
      add :customer_type_id, :string, primary_key: true, size: 5
      add :customer_desc, :text

      timestamps()
    end
  end
end
