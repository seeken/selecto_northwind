defmodule SelectoNorthwind.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :last_name, :string, null: false, size: 20
      add :first_name, :string, null: false, size: 10
      add :title, :string, size: 30
      add :title_of_courtesy, :string, size: 25
      add :birth_date, :date
      add :hire_date, :date
      add :address, :string, size: 60
      add :city, :string, size: 15
      add :region, :string, size: 15
      add :postal_code, :string, size: 10
      add :country, :string, size: 15
      add :home_phone, :string, size: 24
      add :extension, :string, size: 4
      add :photo, :binary
      add :notes, :text
      add :reports_to, references(:employees, on_delete: :nilify_all)
      add :photo_path, :string, size: 255

      timestamps()
    end

    create index(:employees, [:reports_to])
    create index(:employees, [:last_name])
    create index(:employees, [:postal_code])
  end
end
