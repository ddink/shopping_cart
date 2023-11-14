defmodule ShoppingCart.DataCase do
  use ExUnit.CaseTemplate
  alias ShoppingCart.Schemas.{Cart, Customer, PaymentMethod, ShippingAddress, User}
  alias StoreRepo.Repo
  alias ShoppingCart.Schemas.Orders.Order
  alias Ecto.Changeset

  alias StoreRepo.Accounts.User

  using do
    quote do
      alias Ecto.Changeset
      import ShoppingCart.DataCase
      alias ShoppingCart.Factory
      alias StoreRepo.Repo
    end
  end

  def assert_valid_changeset(params, fields, changeset_fn) when is_list(fields) do
    changeset = changeset_fn.(params)

    assert %Changeset{valid?: true, changes: changes} = changeset

    params = atom_map(params)

    for field <- fields do
      actual = Map.get(changes, field)
      expected = params[field]

      assert actual == expected,
             "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
    end
  end

  def assert_valid_embedded_changeset(params, fields, changeset_fn) when is_list(fields) do
    changeset = changeset_fn.(params)

    embedded_schema_key =
      params
      |> Map.keys()
      |> List.first()
      |> String.to_atom()

    assert %Changeset{valid?: true, changes: changes} = changeset

    embedded_changes =
      changes
      |> Map.get(embedded_schema_key)
      |> Map.get(:changes)

    params =
      atom_map(params)
      |> Map.get(embedded_schema_key)
      |> atom_map

    for field <- fields do
      actual = Map.get(embedded_changes, field)
      expected = params[field]

      assert actual == expected,
             "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
    end
  end

  def assert_invalid_changeset(params, fields, changeset_fn, validation_type)
      when is_list(fields) do
    # changeset = Cart.create_order_changeset(params)
    changeset = changeset_fn.(params)

    assert %Changeset{
             valid?: false,
             errors: errors
           } = changeset

    assert_error_fields(errors, fields, validation_type)
  end

  def assert_error_fields(errors, fields, validation_type) when is_atom(validation_type) do
    for field <- fields do
      assert errors[field], "expected an error for #{field}"
      {_, meta} = errors[field]

      assert meta[:validation] == validation_type,
             "The validation type, #{meta[:validation]}, is incorrect."
    end
  end

  def schema_fields, do: Cart.fields()
  def required_fields, do: Cart.required_fields()
  def order_schema_fields, do: Order.fields()

  def order_schema_fields(:string) do
    Order.fields()
    |> Enum.map(fn x -> to_string(x) end)
  end

  def order_required_schema_fields, do: Order.required_fields()
  def skus_required_schema_fields, do: Order.skus_required_fields()
  def address_schema_fields, do: ShippingAddress.fields()
  def customer_schema_fields, do: Customer.fields()
  def payment_method_schema_fields, do: PaymentMethod.fields()
  def user_schema_fields, do: User.cart_fields()

  def order_skus_required_fields do
    Order.skus_required_fields()
    |> Enum.map(fn x -> to_string(x) end)
  end

  def bad_cart_params do
    %{
      "billing_address" => 0,
      "browser_user_agent" => %{},
      "cookie" => %{},
      "customer" => 0,
      "language" => 0,
      "order" => 0,
      "payment_method" => "not an integer",
      "shipping_address" => "not an integer",
      "user" => "not an integer",
      "user_id" => %{}
    }
  end

  def bad_order_params do
    %{
      "total_transaction_price" => %{},
      "tax_price" => %{},
      "order_price" => %{},
      "currency" => NaiveDateTime.utc_now(),
      "payment_installments" => NaiveDateTime.utc_now(),
      "payment_method" => NaiveDateTime.utc_now(),
      "payment_country" => 0,
      "skus" => 0,
      "status" => 0,
      "cart_id" => %{}
    }
  end

  def bad_address_params do
    %{
      "first_line" => %{},
      "second_line" => %{},
      "city" => NaiveDateTime.utc_now(),
      "state" => NaiveDateTime.utc_now(),
      "country" => NaiveDateTime.utc_now(),
      "postal_code" => %{},
      "phone_number" => %{}
    }
  end

  def bad_customer_params do
    %{
      "first_name" => %{},
      "last_name" => %{},
      "email" => NaiveDateTime.utc_now(),
      "phone_number" => NaiveDateTime.utc_now(),
      "documentation_number" => NaiveDateTime.utc_now()
    }
  end

  def bad_payment_method_params do
    %{
      "cc_token_id" => %{},
      "name" => %{}
    }
  end

  def bad_user_params do
    %{
      "first_name" => %{},
      "last_name" => %{},
      "phone_number" => %{},
      "documentation_number" => %{},
      "documentation_type" => %{},
      "email" => %{},
      "password" => %{},
      "hashed_password" => %{},
      "confirmed_at" => %{}
    }
  end

  def atom_map(string_key_map) do
    for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end
end
