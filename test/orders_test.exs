defmodule OrdersTest do
  use ShoppingCart.DataCase, async: true
  alias Orders.Order
  alias StoreRepo.Repo
  alias ShoppingCart.Schemas.Cart
  import ShoppingCart.Query

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

  describe "get_by_user/1" do
    test "success: it returns all orders associated with a user when given the user" do
      user = Factory.insert(:user)
      cart1 = Factory.insert(:cart)
      cart2 = Factory.insert(:cart)
      cart3 = Factory.insert(:cart)

      update_cart_user_id(cart1, user)
      update_cart_user_id(cart2, user)
      update_cart_user_id(cart3, user)

      cart1 = Repo.get(cart_with_order(), cart1.id)
      cart2 = Repo.get(cart_with_order(), cart2.id)
      cart3 = Repo.get(cart_with_order(), cart3.id)

      assert cart1.user_id == user.id
      assert cart2.user_id == user.id
      assert cart3.user_id == user.id

      assert Enum.sort(Orders.get_by_user(user)) == Enum.sort([cart1.order, cart2.order, cart3.order])
    end

    test "error: it returns nil when there are no orders associated with a user" do
      user = Factory.insert(:user)

      assert Orders.get_by_user(user) == nil
    end
  end

  defp update_cart_user_id(cart, user) do
    changeset = Cart.changeset(cart, %{user_id: user.id})
    Repo.update(changeset)
  end

  describe "get_by_date/1" do
    test "success: it returns all orders with an inserted_at value that matches the given a naive datetime" do
      order1 = Factory.insert(:order)
      order2 = Factory.insert(:order)

      assert Orders.get_by_date(NaiveDateTime.utc_now()) == [order1, order2]
    end

    test "success: it returns all orders with an inserted_at value that matches given datetime's date only" do
      order1 = Factory.insert(:order)
      order2 = Factory.insert(:order)
      now = NaiveDateTime.utc_now()
      date = NaiveDateTime.to_date(now)
      time = Time.new!(20, 0, 0, 0)

      assert Orders.get_by_date(NaiveDateTime.new!(date, time)) == [order1, order2]
    end

    test "error: it returns nil when there are no orders with a matching inserted_at value" do
      assert Orders.get_by_date(NaiveDateTime.utc_now()) == nil
    end
  end

  describe "get_by_payment_method/1" do
    test "success: it returns all orders with a payment_method value that matches the given payment method" do
      order1 = Factory.insert(:static_value_order)
      order2 = Factory.insert(:static_value_order)
      order3 = Factory.insert(:static_value_order)

      assert Orders.get_by_payment_method(order1.payment_method) == [order1, order2, order3]
    end

    test "error: it returns nil where there are no orders witih a matching payment_method value" do
      Factory.insert(:static_value_order)
      Factory.insert(:static_value_order)
      Factory.insert(:static_value_order)

      assert Orders.get_by_payment_method("EFECTY") == nil
    end
  end

  describe "get_orders_by_payment_country/1" do
    test "success: it returns all orders with a payment_country value that matches the given country code" do
      order1 = Factory.insert(:static_value_order)
      order2 = Factory.insert(:static_value_order)
      order3 = Factory.insert(:static_value_order)

      assert Orders.get_by_payment_country(order1.payment_country) == [order1, order2, order3]
    end

    test "error: it returns nil where there are no orders witih a matching payment_country value" do
      Factory.insert(:static_value_order)
      Factory.insert(:static_value_order)
      Factory.insert(:static_value_order)

      assert Orders.get_by_payment_method("US") == nil
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
