defmodule ShoppingCart.UserBehaviour do
  @type changeset :: %Ecto.Changeset{}
  @type params :: %{
          String.t() => String.t(),
          String.t() => map()
        }

  @doc """
  Returns list of schema's available fields
  """
  @callback fields() :: [Atom.t()]

  @doc """
  Returns list of schema's fields allowed to be updated by cart-related changesets
  """
  @callback cart_fields() :: [Atom.t()]

  @doc """
  Returns changeset for updating user
  """
  @callback changeset(params) :: changeset
  @callback changeset(struct(), params) :: changeset

  @doc """
  Returns changeset for updating user via a cart changeset
  """
  @callback update_cart_changeset(struct(), params) :: changeset
end
