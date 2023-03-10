defmodule Orders do
  alias Orders.Order
  alias StoreRepo.Repo
  import ShoppingCart.Query

  # Create
  def create_order(params) do
    %Order{}
    |> Order.create_changeset(params)
    |> Repo.insert()
  end

  # Read
  def get_order(id), do: Repo.get(Order, id)

  def get_by_user(user) do 
    case Repo.all(user_orders_query(user.id)) do
      [] ->
        nil
      orders ->
        orders
    end
  end

  def get_by_date(datetime) do
    case Repo.all(date_orders_query(datetime)) do
      [] ->
        nil
      orders ->
        orders
    end
  end

  def get_by_payment_method(payment_method) do
    case Repo.all(orders_by_payment_method_query(payment_method)) do
      [] ->
        nil
      orders ->
        orders
    end
  end

  def get_by_payment_country(country_code) do
    case Repo.all(orders_by_payment_country_query(country_code)) do
      [] ->
        nil
      orders ->
        orders
    end
  end

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
