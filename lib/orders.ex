defmodule Orders do
  alias Orders.Order
  alias ShoppingCart.Repo

  # Create
  def create_order(params) do
    %Order{}
    |> Order.create_changeset(params)
    |> Repo.insert()
  end

  # Read
  def get_order(id), do: Repo.get(Order, id)

  # Update
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def update_order_skus(%Order{} = order, attrs) do
    order
    |> Order.update_skus_changeset(attrs)
    |> Repo.update()
  end

  # Delete
  def delete_order(%Order{} = order) do
    order
    |> Order.delete_changeset()
    |> Repo.delete()
  end
end
