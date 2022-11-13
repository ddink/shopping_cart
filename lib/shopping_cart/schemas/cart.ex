defmodule ShoppingCart.Schemas.Cart do
  use Ecto.Schema
  import Ecto.Changeset
  alias ShoppingCart.Schemas.{ShippingAddress, BillingAddress, Customer, PaymentMethod, User}
  alias Orders.Order

  @supported_languages ["en", "es", "pt"]

  schema "carts" do
    field(:cookie, :string)
    field(:browser_user_agent, :string)
    field(:language, :string)
    timestamps()

    belongs_to(:user, User, on_replace: :update)

    has_one(:order, Order, on_delete: :nilify_all, on_replace: :update)

    embeds_one(:shipping_address, ShippingAddress, on_replace: :update)
    embeds_one(:billing_address, BillingAddress, on_replace: :update)
    embeds_one(:customer, Customer, on_replace: :delete)
    embeds_one(:payment_method, PaymentMethod, on_replace: :delete)
  end

  def fields do
    __MODULE__.__schema__(:fields) -- [:id, :inserted_at, :updated_at]
  end

  def required_fields do
    [:cookie, :browser_user_agent, :language, :user_id]
  end

  def changeset(params) when is_map(params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = cart, params) do
    cart
    |> cast(params, required_fields())
    |> cast_embed(:billing_address, with: &BillingAddress.changeset/2)
    |> cast_embed(:customer, with: &Customer.changeset/2)
    |> cast_assoc(:order, with: &Order.changeset/2)
    |> cast_embed(:payment_method, with: &PaymentMethod.changeset/2)
    |> cast_embed(:shipping_address, with: &ShippingAddress.changeset/2)
    |> cast_assoc(:user, with: &User.changeset/2)
    |> validate_inclusion(:language, @supported_languages)
  end

  # Create Changesets

  def create_changeset(params), do: create_changeset(%__MODULE__{}, params)

  def create_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> validate_required(required_fields())
  end

  def create_order_changeset(params), do: create_order_changeset(%__MODULE__{}, params)

  def create_order_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> cast_assoc(:order, with: &Order.create_changeset/2)
  end

  def create_shipping_address_changeset(params) do
    create_shipping_address_changeset(%__MODULE__{}, params)
  end

  def create_shipping_address_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> validate_required(:shipping_address)
    |> cast_embed(:shipping_address, with: &ShippingAddress.create_changeset/2)
  end

  def create_billing_address_changeset(params) do
    create_billing_address_changeset(%__MODULE__{}, params)
  end

  def create_billing_address_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> validate_required(:billing_address)
    |> cast_embed(:billing_address, with: &BillingAddress.create_changeset/2)
  end

  def create_customer_changeset(params) do
    create_customer_changeset(%__MODULE__{}, params)
  end

  def create_customer_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> validate_required(:customer)
    |> cast_embed(:customer, with: &Customer.create_changeset/2)
  end

  def create_payment_method_changeset(params) do
    create_payment_method_changeset(%__MODULE__{}, params)
  end

  def create_payment_method_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> cast_embed(:payment_method, with: &PaymentMethod.create_changeset/2)
  end

  # Update Changesets

  def update_order_changeset(params), do: update_order_changeset(%__MODULE__{}, params)

  def update_order_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> cast_assoc(:order, with: &Order.changeset/2)
  end

  def update_order_skus_changeset(params), do: update_order_skus_changeset(%__MODULE__{}, params)

  def update_order_skus_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> cast_assoc(:order, with: &Order.update_skus_changeset/2)
  end

  def update_shipping_address_changeset(params) do
    update_shipping_address_changeset(%__MODULE__{}, params)
  end

  def update_shipping_address_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> validate_required(:shipping_address)
  end

  def update_billing_address_changeset(params) do
    update_billing_address_changeset(%__MODULE__{}, params)
  end

  def update_billing_address_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> validate_required(:billing_address)
  end

  def update_customer_changeset(params) do
    update_customer_changeset(%__MODULE__{}, params)
  end

  def update_customer_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> validate_required(:customer)
    |> cast_embed(:customer)
  end  

  def update_payment_method_changeset(params) do
    update_payment_method_changeset(%__MODULE__{}, params)
  end

  def update_payment_method_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> validate_required(:payment_method)
    |> cast_embed(:payment_method)
  end

  def update_user_changeset(params) do
    update_user_changeset(%__MODULE__{}, params)
  end

  def update_user_changeset(%__MODULE__{} = cart, params) do
    cart
    |> changeset(params)
    |> validate_required(:user)
    |> cast_assoc(:user, with: &User.update_cart_changeset/2)
  end

  # Delete Changesets

  def delete_changeset(%__MODULE__{} = cart) do
    cart
    |> changeset(%{})
  end

  def delete_billing_address_changeset(%__MODULE__{} = cart) do
    cart
    |> change
    |> put_embed(:billing_address, nil)
  end

  def delete_shipping_address_changeset(%__MODULE__{} = cart) do
    cart
    |> change
    |> put_embed(:shipping_address, nil)
  end

  def delete_customer_changeset(%__MODULE__{} = cart) do
    cart
    |> change
    |> put_embed(:customer, nil)
  end

  def delete_payment_method_changeset(%__MODULE__{} = cart) do
    cart
    |> change
    |> put_embed(:payment_method, nil)
  end
end
