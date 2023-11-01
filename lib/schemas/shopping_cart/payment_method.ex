defmodule ShoppingCart.Schemas.PaymentMethod do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:cc_number, :string)
    field(:cc_security_code, :string)
    field(:cc_expiration_date, :string)
    field(:cc_name, :string)
    field(:cc_token_id, :string)
    field(:name, :string)
  end

  def fields do
    # Only name and cc_token_id are available to persist
    [:name, :cc_token_id]
  end

  def changeset(params), do: changeset(%__MODULE__{}, params)
  # automatically available to ShoppingCart.Cart.changeset/2
  def changeset(%__MODULE__{} = payment_method, params) do
    payment_method
    |> cast(params, fields())
  end

  def create_changeset(params), do: create_changeset(%__MODULE__{}, params)

  def create_changeset(%__MODULE__{} = payment_method, params) do
    payment_method
    |> changeset(params)
    |> validate_required(:name)
  end
end
