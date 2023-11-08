defmodule ShoppingCart.Schemas.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @order_statuses [
    "Pre-checkout",
    "Ready for payment",
    "Post-checkout",
    "Preparing for shipping",
    "Shipped",
    "Delivered"
  ]

  schema "orders" do
    field(:total_transaction_price, :integer)
    field(:tax_price, :integer)
    field(:order_price, :integer)
    field(:currency, :string)
    field(:payment_installments, :integer)
    field(:payment_method, :string)
    field(:payment_country, :string)
    field(:skus, {:map, :string})
    field(:status, :string)
    timestamps()

    belongs_to(:cart, ShoppingCart.Schemas.Cart, type: :binary_id)
  end

  def fields do
    __MODULE__.__schema__(:fields) -- [:id, :inserted_at, :updated_at]
  end

  # These are fields that don't need to have values until
  # the "ready_for_payment" status phase
  defp optional_fields,
    do: [:status, :currency, :payment_installments, :payment_method, :payment_country]

  def required_fields, do: fields() -- optional_fields()

  def skus_required_fields, do: [:total_transaction_price, :tax_price, :order_price, :skus]

  def changeset(params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = order, params) do
    order
    |> cast(params, fields())
    |> validate_inclusion(:status, @order_statuses)
  end

  def create_changeset(params), do: create_changeset(%__MODULE__{}, params)

  def create_changeset(%__MODULE__{} = order, params) do
    order
    |> changeset(params)
    |> validate_required(required_fields())
    |> change(status: "pre_checkout")
  end

  def update_skus_changeset(params) do
    update_skus_changeset(%__MODULE__{}, params)
  end

  def update_skus_changeset(%__MODULE__{} = order, params) do
    order
    |> changeset(params)
    |> validate_required(skus_required_fields())
  end

  def delete_changeset(%__MODULE__{} = order) do
    order |> change
  end

  def order_statuses, do: @order_statuses
end
