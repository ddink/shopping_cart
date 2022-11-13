defmodule ShoppingCart.Repo.Migrations.AddCartsTable do
  use Ecto.Migration

  def change do
    create table("carts") do
      add :cookie, :string
      add :browser_user_agent, :string
      add :language, :string

      add :user_id, references(:users, on_delete: :nothing)

      add :shipping_address, :map
      add :billing_address, :map
      add :customer, :map
      add :payment_method, :map
      timestamps()
    end
  end
end
