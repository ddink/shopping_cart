defmodule ShoppingCart.Repo.Migrations.AddOrdersTable do
  use Ecto.Migration

  def change do
    create table("orders") do
      add :total_transaction_price, :integer
      add :tax_price, :integer
      add :order_price, :integer
      add :currency, :string
      add :payment_installments, :integer
      add :payment_method, :string
      add :payment_country, :string
      add :skus, {:map, :string}
      add :cart_id, references(:carts, on_delete: :nothing)
      add :status, :string
      timestamps()
    end
  end
end
