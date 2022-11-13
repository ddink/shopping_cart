defmodule OrdersTest do
  use ShoppingCart.DataCase, async: true
  alias Orders.Order

  describe "create_order" do
    test "success: it inserts an order in the db and returns the order" do
      params = Factory.string_params_for(:order_with_cart_id)

      assert {:ok, %Order{} = returned_order} = Orders.create_order(params)

      order_from_db = Repo.get(Order, returned_order.id)
      assert returned_order == order_from_db

      # excludes status field because it's prepopulated when an order is created
      for {param_field, expected} <- params, param_field not in ["status"] do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(order_from_db, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert order_from_db.inserted_at == order_from_db.updated_at
    end

    test "error: returns an error tuple when order can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Orders.create_order(missing_params)
    end
  end

  describe "get_order/1" do
    test "success: it returns an order when given a valid id" do
      existing_order = Factory.insert(:order)

      assert %Order{} = returned_order = ShoppingCart.get_order(existing_order.id)

      assert returned_order == existing_order
    end

    test "error: it returns nil when an order doesn't exist" do
      assert nil == ShoppingCart.get_order(Enum.random(10..10000))
    end
  end

  describe "update_order/2" do
    test "success: it updates database and returns the order" do
      existing_order = Factory.insert(:order_from_last_month)
      params = %{"currency" => "GBP"}
      # Factory.string_params_for(:static_value_order) 
      # |> Map.take(["currency"])

      assert {:ok, %Order{} = returned_order} = Orders.update_order(existing_order, params)

      order_from_db = Repo.get(Order, returned_order.id)
      assert returned_order == order_from_db

      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_order, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_order.inserted_at == order_from_db.inserted_at
      refute existing_order.updated_at == order_from_db.updated_at
      assert %NaiveDateTime{} = order_from_db.updated_at
    end

    test "error: returns an error tuple when order can't be updated" do
      existing_order = Factory.insert(:order)

      bad_params = %{
        "total_transaction_price" => %{},
        "tax_price" => NaiveDateTime.utc_now(),
        "order_price" => %{},
        "currency" => 0,
        "payment_installments" => NaiveDateTime.utc_now(),
        "payment_method" => %{},
        "payment_country" => 0,
        "skus" => "",
        "status" => %{},
        "cart_id" => ""
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               Orders.update_order(existing_order, bad_params)

      assert existing_order == Repo.get(Order, existing_order.id)
    end
  end

  describe "update_order_skus/2" do
    test "success: it updates database and returns the order" do
      existing_order = Factory.insert(:order_from_last_month)

      params =
        Factory.string_params_for(:order)
        |> Map.take(order_skus_required_fields())

      assert {:ok, %Order{} = returned_order} = Orders.update_order_skus(existing_order, params)

      order_from_db = Repo.get(Order, returned_order.id)
      assert returned_order == order_from_db

      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_order, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_order.inserted_at == order_from_db.inserted_at
      refute existing_order.updated_at == order_from_db.updated_at
      assert %NaiveDateTime{} = order_from_db.updated_at
    end

    test "error: returns an error tuple when order can't be updated" do
      existing_order = Factory.insert(:order)

      bad_params = %{
        "total_transaction_price" => %{},
        "tax_price" => NaiveDateTime.utc_now(),
        "order_price" => %{},
        "currency" => 0,
        "skus" => ""
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               Orders.update_order_skus(existing_order, bad_params)

      assert existing_order == Repo.get(Order, existing_order.id)
    end
  end

  describe "delete_order/1" do
    test "success: it deletes the order when passed the order" do
      order = Factory.insert(:order)

      assert {:ok, _deleted_cart} = Orders.delete_order(order)

      refute Repo.get(Order, order.id)
    end
  end
end
