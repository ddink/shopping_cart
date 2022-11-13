defmodule ShoppingCart.Schemas.User do
  # Stand in for Accounts.User or whatever user module your application uses.
  # Just make sure to change your alias statement in ShoppingCart.Cart,
  # add a changeset function, 
  # and delete the add_users_table migration if you decide to replace this module 
  # with one that has a different naming convention...
  # ...............
  # Ok, fine, I'll just make this a behavior
  use Ecto.Schema
  import Ecto.Changeset

  @behaviour ShoppingCart.UserBehaviour

  schema "users" do
    field(:name, :string)
    timestamps()
  end

  def fields do
    __MODULE__.__schema__(:fields) -- [:id, :inserted_at, :updated_at]
  end

  def cart_fields do
    # This is where we'll put a default_token_id attribute 
    # after refactoring the migration
    [:name]
  end

  def changeset(params), do: changeset(%__MODULE__{}, params)

  def changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, fields())
  end

  def update_cart_changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, [:name])
  end
end
