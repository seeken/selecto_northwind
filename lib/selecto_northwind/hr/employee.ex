defmodule SelectoNorthwind.Hr.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employees" do
    field :last_name, :string
    field :first_name, :string
    field :title, :string
    field :title_of_courtesy, :string
    field :birth_date, :date
    field :hire_date, :date
    field :address, :string
    field :city, :string
    field :region, :string
    field :postal_code, :string
    field :country, :string
    field :home_phone, :string
    field :extension, :string
    field :photo, :binary
    field :notes, :string
    field :photo_path, :string

    belongs_to :manager, SelectoNorthwind.Hr.Employee, foreign_key: :reports_to

    has_many :subordinates, SelectoNorthwind.Hr.Employee, foreign_key: :reports_to
    has_many :orders, SelectoNorthwind.Sales.Order

    many_to_many :territories, SelectoNorthwind.Geography.Territory,
      join_through: SelectoNorthwind.Hr.EmployeeTerritory,
      join_keys: [employee_id: :id, territory_id: :territory_id]

    timestamps()
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [
      :last_name,
      :first_name,
      :title,
      :title_of_courtesy,
      :birth_date,
      :hire_date,
      :address,
      :city,
      :region,
      :postal_code,
      :country,
      :home_phone,
      :extension,
      :photo,
      :notes,
      :reports_to,
      :photo_path
    ])
    |> validate_required([:last_name, :first_name])
    |> validate_length(:last_name, max: 20)
    |> validate_length(:first_name, max: 10)
    |> validate_length(:title, max: 30)
    |> validate_length(:title_of_courtesy, max: 25)
    |> validate_length(:address, max: 60)
    |> validate_length(:city, max: 15)
    |> validate_length(:region, max: 15)
    |> validate_length(:postal_code, max: 10)
    |> validate_length(:country, max: 15)
    |> validate_length(:home_phone, max: 24)
    |> validate_length(:extension, max: 4)
    |> validate_length(:photo_path, max: 255)
    |> foreign_key_constraint(:reports_to)
  end

  def full_name(%SelectoNorthwind.Hr.Employee{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end
end
