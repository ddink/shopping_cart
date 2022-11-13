defmodule ShoppingCart do
  alias ShoppingCart.Schemas.{
    BillingAddress,
    ShippingAddress,
    Cart,
    Customer,
    PaymentMethod,
    User
  }

  alias ShoppingCart.Repo
  alias Orders.Order
  import ShoppingCart.Query

  # Create
  def create_cart(attrs) do
    %Cart{}
    |> Cart.create_changeset(attrs)
    |> Repo.insert()
  end

  def add_billing_address(%Cart{} = cart, attrs) do
    cart
    |> Cart.create_billing_address_changeset(attrs)
    |> Repo.update()
  end

  def add_shipping_address(%Cart{} = cart, attrs) do
    cart
    |> Cart.create_shipping_address_changeset(attrs)
    |> Repo.update()
  end

  def add_customer(%Cart{} = cart, attrs) do
    cart
    |> Cart.create_customer_changeset(attrs)
    |> Repo.update()
  end

  def add_payment_method(%Cart{} = cart, attrs) do
    cart
    |> Cart.create_payment_method_changeset(attrs)
    |> Repo.update()
  end

  def create_order(%Cart{} = cart, attrs) do
    cart
    |> Cart.create_order_changeset(attrs)
    |> Repo.update()
  end

  # Read
  def get_cart(cart_id), do: Repo.get(Cart, cart_id) |> Repo.preload([:user, :order])

  def get_user(user_id) when is_integer(user_id), do: Repo.get(User, user_id)

  def get_order(order_id) when is_integer(order_id), do: Orders.get_order(order_id)

  def get_cart_by_billing_address(%BillingAddress{} = address) do
    Repo.get_by(cart_with_user_and_order(), billing_address: address)
  end

  def get_cart_by_shipping_address(%ShippingAddress{} = address) do
    Repo.get_by(cart_with_user_and_order(), shipping_address: address)
  end

  def get_cart_by_customer(%Customer{} = customer) do
    Repo.get_by(cart_with_user_and_order(), customer: customer)
  end

  def get_cart_by_payment_method(%PaymentMethod{} = payment_method) do
    Repo.get_by(cart_with_user_and_order(), payment_method: payment_method)
  end

  def get_cart_by_order(order) when is_nil(order.cart_id), do: nil

  def get_cart_by_order(%Order{} = order) do
    Repo.get(cart_with_user_and_order(), order.cart_id)
  end

  def get_cart_by_user(%User{} = user) do
    Repo.get_by(cart_with_user_and_order(), user_id: user.id)
  end

  # Update
  def update_cart(%Cart{} = cart, attrs) do
    cart
    |> Cart.changeset(attrs)
    |> Repo.update()
  end

  def update_billing_address(%Cart{} = cart, attrs) do
    cart
    |> Cart.update_billing_address_changeset(attrs)
    |> Repo.update()
  end

  def update_shipping_address(%Cart{} = cart, attrs) do
    cart
    |> Cart.update_shipping_address_changeset(attrs)
    |> Repo.update()
  end

  def update_customer(%Cart{} = cart, attrs) do
    cart
    |> Cart.update_customer_changeset(attrs)
    |> Repo.update()
  end

  def update_payment_method(%Cart{} = cart, attrs) do
    cart
    |> Cart.update_payment_method_changeset(attrs)
    |> Repo.update()
  end

  def update_order(cart, _attrs) when is_nil(cart.order), do: nil

  def update_order(%Cart{} = cart, attrs) do
    cart
    |> Cart.update_order_changeset(attrs)
    |> Repo.update()
  end

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def update_order_skus(cart, _attrs) when is_nil(cart.order), do: nil

  def update_order_skus(%Cart{} = cart, attrs) do
    cart
    |> Cart.update_order_skus_changeset(attrs)
    |> Repo.update()
  end

  def update_order_skus(%Order{} = order, attrs) do
    order
    |> Order.update_skus_changeset(attrs)
    |> Repo.update()
  end

  def update_user(cart, _attrs) when is_nil(cart.user), do: nil

  def update_user(%Cart{} = cart, attrs) do
    cart
    |> Cart.update_user_changeset(attrs)
    |> Repo.update()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  # Delete
  def delete_cart(%Cart{} = cart) do
    cart
    |> Cart.delete_changeset()
    |> Repo.delete()
  end

  def delete_billing_address(%Cart{} = cart) do
    cart
    |> Cart.delete_billing_address_changeset()
    |> Repo.update()
  end

  def delete_shipping_address(%Cart{} = cart) do
    cart
    |> Cart.delete_shipping_address_changeset()
    |> Repo.update()
  end

  def delete_customer(%Cart{} = cart) do
    cart
    |> Cart.delete_customer_changeset()
    |> Repo.update()
  end

  def delete_payment_method(%Cart{} = cart) do
    cart
    |> Cart.delete_payment_method_changeset()
    |> Repo.update()
  end

  def delete_order(%Cart{} = cart) do
    cart.order
    |> Order.delete_changeset()
    |> Repo.delete()
  end

  def delete_order(%Order{} = order) do
    order
    |> Order.delete_changeset()
    |> Repo.delete()
  end
end
