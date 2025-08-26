defmodule SelectoNorthwind.Geography.UsState do
  use Ecto.Schema
  import Ecto.Changeset

  schema "us_states" do
    field :state_name, :string
    field :state_abbr, :string
    field :state_region, :string

    timestamps()
  end

  @doc false
  def changeset(us_state, attrs) do
    us_state
    |> cast(attrs, [:state_name, :state_abbr, :state_region])
    |> validate_length(:state_name, max: 100)
    |> validate_length(:state_abbr, max: 2)
    |> validate_length(:state_region, max: 50)
    |> unique_constraint(:state_abbr)
  end
end
