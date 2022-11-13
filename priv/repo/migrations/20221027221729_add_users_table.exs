# Feel free to remove this migration--it was only necessary for testing purposes during development
defmodule ShoppingCart.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :name, :string
      timestamps()
    end
  end
end
