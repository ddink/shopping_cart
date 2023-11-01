defmodule ShoppingCart.Schemas.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:phone_number, :string)
    field(:documentation_number, :string)
  end

  def fields do
    __MODULE__.__schema__(:fields) -- [:id, :inserted_at, :updated_at]
  end

  def changeset(params), do: changeset(%__MODULE__{}, params)
  # automatically available to ShoppingCart.Cart.changeset/2
  def changeset(%__MODULE__{} = customer, params) do
    customer
    |> cast(params, fields())
  end

  def create_changeset(params), do: create_changeset(%__MODULE__{}, params)

  def create_changeset(%__MODULE__{} = customer, params) do
    customer
    |> changeset(params)
    |> validate_required(fields())
  end
end
