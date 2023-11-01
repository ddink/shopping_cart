defmodule ShoppingCart.Schemas.ShippingAddress do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:first_line, :string)
    field(:second_line, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)
    field(:postal_code, :string)
    field(:phone_number, :string)
  end

  def fields do
    __MODULE__.__schema__(:fields) -- [:id, :inserted_at, :updated_at]
  end

  def changeset(params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = address, params) do
    address |> cast(params, fields())
  end

  def create_changeset(params), do: create_changeset(%__MODULE__{}, params)

  def create_changeset(%__MODULE__{} = address, params) do
    address
    |> changeset(params)
    |> validate_required(fields())
  end
end
