defmodule SelectoNorthwind.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :text, null: false
      add :commentable_type, :string, null: false
      # String to support both integer and string IDs
      add :commentable_id, :string, null: false
      add :user_name, :string

      timestamps()
    end

    # Composite index for polymorphic lookups
    create index(:comments, [:commentable_type, :commentable_id])
  end
end
