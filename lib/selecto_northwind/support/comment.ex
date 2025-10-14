defmodule SelectoNorthwind.Support.Comment do
  @moduledoc """
  Schema for polymorphic comments that can belong to Products, Orders, or Customers.

  Demonstrates Mode 4: Polymorphic join mode with type + id pattern.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string
    field :commentable_type, :string
    field :commentable_id, :integer
    field :user_name, :string

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :commentable_type, :commentable_id, :user_name])
    |> validate_required([:body, :commentable_type, :commentable_id])
    |> validate_inclusion(:commentable_type, ["Product", "Order", "Customer"])
  end
end
