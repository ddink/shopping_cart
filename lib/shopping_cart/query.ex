defmodule ShoppingCart.Query do
  import Ecto.Query
  alias ShoppingCart.Schemas.Cart
  alias ShoppingCart.Schemas.Orders.Order

  def cart_with_order do
    from(c in Cart,
      join: o in assoc(c, :order),
      preload: [order: o]
    )
  end

  def cart_with_user_and_order do
    from(c in Cart,
      join: u in assoc(c, :user),
      join: o in assoc(c, :order),
      preload: [user: u, order: o]
    )
  end

  def user_orders_query(user_id) do
    from(o in Order,
      join: c in assoc(o, :cart),
      where: c.user_id == ^user_id
    )
  end

  def date_orders_query(datetime) do
    date = NaiveDateTime.to_date(datetime)
    begin_time = Time.new!(0, 0, 0, 0)
    end_time = Time.new!(23, 59, 59, 999_999)
    begin_datetime = NaiveDateTime.new!(date, begin_time)
    end_datetime = NaiveDateTime.new!(date, end_time)

    from(o in Order,
      where: o.inserted_at >= ^begin_datetime and o.inserted_at <= ^end_datetime
    )
  end

  def orders_by_payment_method_query(payment_method) do
    from(o in Order,
      where: o.payment_method == ^payment_method
    )
  end

  def orders_by_payment_country_query(country_code) do
    from(o in Order,
      where: o.payment_country == ^country_code
    )
  end
 end
