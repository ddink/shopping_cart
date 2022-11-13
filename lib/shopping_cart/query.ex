defmodule ShoppingCart.Query do
  import Ecto.Query
  alias ShoppingCart.Schemas.Cart

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
end
