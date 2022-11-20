defmodule ShoppingCartTest do
  use ShoppingCart.DataCase, async: true
  alias ShoppingCart.Schemas.{Cart, User}
  alias StoreRepo.Repo
  alias Orders.Order
  import ShoppingCart.Query

  # Create Tests
  describe "create_cart/1" do
    test "success: it inserts a cart in the db and returns the cart" do
      embedded_schemas = [
        "customer",
        "billing_address",
        "shipping_address",
        "payment_method",
        "user",
        "order"
      ]

      params = Factory.string_params_for(:cart_with_no_order)

      assert {:ok, %Cart{} = returned_cart} = ShoppingCart.create_cart(params)

      cart_from_db = Repo.get(Cart, returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- params,
          param_field not in embedded_schemas do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(cart_from_db, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert cart_from_db.inserted_at == cart_from_db.updated_at
    end

    test "error: returns an error tuple when user can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = ShoppingCart.create_cart(missing_params)
    end
  end

  describe "add_billing_address/2" do
    test "success: it inserts a billing address in the db and returns the cart containing the billing address" do
      existing_cart = Factory.insert(:empty_cart)
      address_params = Factory.string_params_for(:billing_address)
      params = %{"billing_address" => address_params}

      assert {:ok, %Cart{} = returned_cart} =
               ShoppingCart.add_billing_address(existing_cart, params)

      cart_from_db = Repo.get(cart_with_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- address_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.billing_address, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      refute existing_cart.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "error: returns an error tuple when billing address can't be created" do
      existing_cart = Factory.insert(:empty_cart)

      bad_params = %{
        "billing_address" => bad_address_params()
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.add_billing_address(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_order(), existing_cart.id)
    end
  end

  describe "add_shipping_address/2" do
    test "success: it inserts a shipping address in the db and returns the cart containing the shipping address" do
      existing_cart = Factory.insert(:empty_cart)
      address_params = Factory.string_params_for(:shipping_address)
      params = %{"shipping_address" => address_params}

      assert {:ok, %Cart{} = returned_cart} =
               ShoppingCart.add_shipping_address(existing_cart, params)

      cart_from_db = Repo.get(cart_with_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- address_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.shipping_address, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      refute existing_cart.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "error: returns an error tuple when shipping address can't be created" do
      existing_cart = Factory.insert(:empty_cart)

      bad_params = %{
        "shipping_address" => bad_address_params()
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.add_shipping_address(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_order(), existing_cart.id)
    end
  end

  describe "add_customer/2" do
    test "success: it inserts a customer in the db and returns the cart containing the customer" do
      existing_cart = Factory.insert(:empty_cart)
      customer_params = Factory.string_params_for(:customer)
      params = %{"customer" => customer_params}

      assert {:ok, %Cart{} = returned_cart} = ShoppingCart.add_customer(existing_cart, params)

      cart_from_db = Repo.get(cart_with_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- customer_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.customer, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      refute existing_cart.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "error: returns an error tuple when customer can't be created" do
      existing_cart = Factory.insert(:empty_cart)

      bad_params = %{
        "customer" => bad_customer_params()
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.add_customer(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_order(), existing_cart.id)
    end
  end

  describe "add_payment_method/2" do
    test "success: it inserts a payment method in the db and returns the cart containing the payment method" do
      existing_cart = Factory.insert(:empty_cart)
      payment_method_params = Factory.string_params_for(:payment_method)
      params = %{"payment_method" => payment_method_params}

      assert {:ok, %Cart{} = returned_cart} =
               ShoppingCart.add_payment_method(existing_cart, params)

      cart_from_db = Repo.get(cart_with_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- payment_method_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.payment_method, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      refute existing_cart.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "error: returns an error tuple when payment method can't be created" do
      existing_cart = Factory.insert(:empty_cart)
      bad_params = %{"payment_method" => bad_payment_method_params()}

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.add_payment_method(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_order(), existing_cart.id)
    end
  end

  describe "create_order/2" do
    test "success: it inserts a order in the db and returns the cart containing the order" do
      existing_cart = Factory.insert(:empty_cart_no_order)
      order_params = Factory.string_params_for(:order) |> Map.put("cart_id", existing_cart.id)
      params = %{"order" => order_params}

      assert {:ok, %Cart{} = returned_cart} = ShoppingCart.create_order(existing_cart, params)

      cart_from_db = Repo.get(cart_with_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      # adds guard for status field because they're pre-populated to be "pre-checkout" when created
      for {param_field, expected} <- order_params,
          param_field not in ["status"] do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.order, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      refute existing_cart.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "error: returns an error tuple when order can't be created" do
      existing_cart = Factory.insert(:empty_cart_no_order)

      bad_params = %{
        "order" => bad_order_params()
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.create_order(existing_cart, bad_params)

      cart_from_db = Repo.get(Cart, existing_cart.id)
      assert existing_cart.inserted_at == cart_from_db.inserted_at
    end
  end

  # Read Tests
  describe "get_cart/1" do
    test "success: it returns a cart when given a valid id" do
      existing_cart = Factory.insert(:cart)

      assert %Cart{} = returned_cart = ShoppingCart.get_cart(existing_cart.id)

      assert returned_cart == existing_cart
    end

    test "error: it returns nil when a cart doesn't exist" do
      assert nil == ShoppingCart.get_cart(Enum.random(10..10000))
    end
  end

  describe "get_user/1" do
    test "success: it returns a user when given a valid id" do
      existing_user = Factory.insert(:user)

      assert %User{} = returned_user = ShoppingCart.get_user(existing_user.id)

      assert returned_user == existing_user
    end

    test "error: it returns nil when a user doesn't exist" do
      assert nil == ShoppingCart.get_user(Enum.random(10..10000))
    end
  end

  describe "get_order/1" do
    test "success: it returns a order when given a valid id" do
      existing_order = Factory.insert(:order)

      assert %Order{} = returned_order = ShoppingCart.get_order(existing_order.id)

      assert returned_order == existing_order
    end

    test "error: it returns nil when a order doesn't exist" do
      assert nil == ShoppingCart.get_order(Enum.random(10..10000))
    end
  end

  describe "get_cart_by_billing_address/1" do
    test "success: it returns a cart when given an embedded billing address" do
      existing_cart = Factory.insert(:cart)
      existing_address = existing_cart |> Map.get(:billing_address)

      assert %Cart{} = returned_cart = ShoppingCart.get_cart_by_billing_address(existing_address)

      assert returned_cart == existing_cart
    end

    test "error: it returns nil when billing address is not embedded within cart" do
      existing_address = Factory.build(:billing_address)
      assert nil == ShoppingCart.get_cart_by_billing_address(existing_address)
    end
  end

  describe "get_cart_by_shipping_address/1" do
    test "success: it returns a cart when given an embedded shipping address" do
      existing_cart = Factory.insert(:cart)
      existing_address = existing_cart |> Map.get(:shipping_address)

      assert %Cart{} = returned_cart = ShoppingCart.get_cart_by_shipping_address(existing_address)

      assert returned_cart == existing_cart
    end

    test "error: it returns nil when billing address is not embedded within cart" do
      existing_address = Factory.build(:shipping_address)
      assert nil == ShoppingCart.get_cart_by_shipping_address(existing_address)
    end
  end

  describe "get_cart_by_customer/1" do
    test "success: it returns a cart when given an embedded customer" do
      existing_cart = Factory.insert(:cart)
      existing_customer = existing_cart |> Map.get(:customer)

      assert %Cart{} = returned_cart = ShoppingCart.get_cart_by_customer(existing_customer)

      assert returned_cart == existing_cart
    end

    test "error: it returns nil when billing address is not embedded within cart" do
      existing_customer = Factory.build(:customer)
      assert nil == ShoppingCart.get_cart_by_customer(existing_customer)
    end
  end

  describe "get_cart_by_payment_method/1" do
    test "success: it returns a cart when given an embedded payment method" do
      existing_cart = Factory.insert(:cart)
      existing_method = existing_cart |> Map.get(:payment_method)

      assert %Cart{} = returned_cart = ShoppingCart.get_cart_by_payment_method(existing_method)

      assert returned_cart == existing_cart
    end

    test "error: it returns nil when payment method is not embedded within cart" do
      existing_method = Factory.build(:payment_method)
      assert nil == ShoppingCart.get_cart_by_payment_method(existing_method)
    end
  end

  describe "get_cart_by_order/1" do
    test "success: it returns a cart when given an associated order" do
      existing_cart = Factory.insert(:cart)
      existing_order = existing_cart |> Map.get(:order)

      assert %Cart{} = returned_cart = ShoppingCart.get_cart_by_order(existing_order)

      assert returned_cart == existing_cart
    end

    test "error: it returns nil when order is not associated with cart" do
      existing_order = Factory.insert(:order)
      assert nil == ShoppingCart.get_cart_by_order(existing_order)
    end
  end

  describe "get_cart_by_user/1" do
    test "success: it returns a cart when given an associated user" do
      existing_cart = Factory.insert(:cart)
      existing_user = existing_cart |> Map.get(:user)

      assert %Cart{} = returned_cart = ShoppingCart.get_cart_by_user(existing_user)

      assert returned_cart == existing_cart
    end

    test "error: it returns nil when user is not associated with cart" do
      existing_user = Factory.insert(:user)
      assert nil == ShoppingCart.get_cart_by_user(existing_user)
    end
  end

  # Update Tests
  describe "update_cart/2" do
    test "success: it updates database and returns the cart" do
      existing_cart = Factory.insert(:empty_cart)

      params =
        Factory.string_params_for(:cart_with_no_order)
        |> Map.take(["cookie"])

      assert {:ok, %Cart{} = returned_cart} = ShoppingCart.update_cart(existing_cart, params)

      cart_from_db = Repo.get(cart_with_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.inserted_at == cart_from_db.inserted_at
      refute existing_cart.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "error: returns an error tuple when cart can't be updated" do
      existing_cart = Factory.insert(:empty_cart)

      bad_params = %{
        "cookie" => NaiveDateTime.utc_now(),
        "language" => NaiveDateTime.utc_now(),
        "user_id" => %{},
        "browser_user_agent" => %{}
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_cart(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_order(), existing_cart.id)
    end
  end

  describe "update_billing_address/2" do
    test "success: it updates database and returns the cart containing the billing address" do
      existing_cart = Factory.insert(:cart_from_last_month)
      embedded_params = Factory.string_params_for(:billing_address)

      params = %{
        "billing_address" => embedded_params
      }

      assert {:ok, %Cart{} = returned_cart} =
               ShoppingCart.update_billing_address(existing_cart, params)

      cart_from_db = Repo.get(cart_with_user_and_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- embedded_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.billing_address, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.inserted_at == cart_from_db.inserted_at
      refute existing_cart.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "error: returns an error tuple when cart's billing address can't be updated" do
      existing_cart = Factory.insert(:cart_from_last_month)

      bad_params = %{
        "billing_address" => bad_address_params()
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_billing_address(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_user_and_order(), existing_cart.id)
    end
  end

  describe "update_shipping_address/2" do
    test "success: it updates database and returns the cart containing the shipping address" do
      existing_cart = Factory.insert(:cart_from_last_month)
      embedded_params = Factory.string_params_for(:shipping_address)

      params = %{
        "shipping_address" => embedded_params
      }

      assert {:ok, %Cart{} = returned_cart} =
               ShoppingCart.update_shipping_address(existing_cart, params)

      cart_from_db = Repo.get(cart_with_user_and_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- embedded_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.shipping_address, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.inserted_at == cart_from_db.inserted_at
      refute existing_cart.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "error: returns an error tuple when cart's shipping address can't be updated" do
      existing_cart = Factory.insert(:cart_from_last_month)

      bad_params = %{
        "shipping_address" => bad_address_params()
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_shipping_address(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_user_and_order(), existing_cart.id)
    end
  end

  describe "update_customer/2" do
    test "success: it updates database and returns the cart containing the customer" do
      existing_cart = Factory.insert(:cart_from_last_month)
      embedded_params = Factory.string_params_for(:customer)

      params = %{
        "customer" => embedded_params
      }

      assert {:ok, %Cart{} = returned_cart} = ShoppingCart.update_customer(existing_cart, params)

      cart_from_db = Repo.get(cart_with_user_and_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- embedded_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.customer, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.inserted_at == cart_from_db.inserted_at
      refute existing_cart.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "error: returns an error tuple when cart's customer can't be updated" do
      existing_cart = Factory.insert(:cart_from_last_month)

      bad_params = %{
        "customer" => bad_customer_params()
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_customer(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_user_and_order(), existing_cart.id)
    end
  end

  describe "update_payment_method/2" do
    test "success: it updates database and returns the cart containing the payment_method" do
      existing_cart = Factory.insert(:cart_from_last_month)
      embedded_params = Factory.string_params_for(:payment_method)

      params = %{
        "payment_method" => embedded_params
      }

      assert {:ok, %Cart{} = returned_cart} =
               ShoppingCart.update_payment_method(existing_cart, params)

      cart_from_db = Repo.get(cart_with_user_and_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- embedded_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.payment_method, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.inserted_at == cart_from_db.inserted_at
      refute existing_cart.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "error: returns an error tuple when cart's payment method can't be updated" do
      existing_cart = Factory.insert(:cart_from_last_month)

      bad_params = %{
        "payment_method" => bad_payment_method_params()
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_payment_method(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_user_and_order(), existing_cart.id)
    end
  end

  describe "update_order/2" do
    test "success: it updates database when given a cart's order & params 
          and returns the cart with updated order" do
      existing_cart = Factory.insert(:cart_from_last_month)
      order_params = Factory.string_params_for(:order)

      params = %{
        "order" => order_params
      }

      assert {:ok, %Cart{} = returned_cart} = ShoppingCart.update_order(existing_cart, params)

      cart_from_db = Repo.get(cart_with_user_and_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- order_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.order, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.order.inserted_at == cart_from_db.inserted_at
      refute existing_cart.order.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "success: it updates database when given an order & params and returns the updated order" do
      existing_cart = Factory.insert(:cart_from_last_month)
      params = Factory.string_params_for(:order)

      assert {:ok, %Order{} = returned_order} =
               ShoppingCart.update_order(existing_cart.order, params)

      order_from_db = Repo.get(Order, returned_order.id)
      assert returned_order == order_from_db

      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_order, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.order.inserted_at == order_from_db.inserted_at
      refute existing_cart.order.updated_at == order_from_db.updated_at
      assert %NaiveDateTime{} = order_from_db.updated_at
    end

    test "error: returns an error tuple when a cart's order can't be updated" do
      existing_cart = Factory.insert(:cart_from_last_month)

      bad_params = %{
        "order" => bad_order_params()
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_order(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_user_and_order(), existing_cart.id)
    end

    test "error: returns an error tuple when a order can't be updated" do
      existing_cart = Factory.insert(:cart_from_last_month)

      bad_params = bad_order_params()

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_order(existing_cart.order, bad_params)

      assert existing_cart == Repo.get(cart_with_user_and_order(), existing_cart.id)
    end
  end

  describe "update_order_skus/2" do
    test "success: it updates database when given a cart's order & params 
          and returns the cart with updated order" do
      existing_cart = Factory.insert(:cart_from_last_month)
      order_params = Factory.string_params_for(:order) |> Map.take(order_skus_required_fields())

      params = %{
        "order" => order_params
      }

      assert {:ok, %Cart{} = returned_cart} =
               ShoppingCart.update_order_skus(existing_cart, params)

      cart_from_db = Repo.get(cart_with_user_and_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- order_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.order, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.order.inserted_at == cart_from_db.inserted_at
      refute existing_cart.order.updated_at == cart_from_db.updated_at
      assert %NaiveDateTime{} = cart_from_db.updated_at
    end

    test "success: it updates database and returns the order" do
      existing_cart = Factory.insert(:cart_from_last_month)
      params = Factory.string_params_for(:order) |> Map.take(order_skus_required_fields())

      assert {:ok, %Order{} = returned_order} =
               ShoppingCart.update_order_skus(existing_cart.order, params)

      order_from_db = Repo.get(Order, returned_order.id)
      assert returned_order == order_from_db

      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_order, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.order.inserted_at == order_from_db.inserted_at
      refute existing_cart.order.updated_at == order_from_db.updated_at
      assert %NaiveDateTime{} = order_from_db.updated_at
    end

    test "error: returns an error tuple when a cart's order can't be updated" do
      existing_cart = Factory.insert(:cart)

      bad_params = bad_order_params() |> Map.take(order_skus_required_fields())

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_order_skus(existing_cart.order, bad_params)

      assert existing_cart == Repo.get(cart_with_user_and_order(), existing_cart.id)
    end

    test "error: returns an error tuple when a order can't be updated" do
      existing_cart = Factory.insert(:cart)

      bad_params = %{
        "order" => bad_order_params() |> Map.take(order_skus_required_fields())
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_order_skus(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_user_and_order(), existing_cart.id)
    end
  end

  describe "update_user/2" do
    test "success: it updates database when given a cart's user and returns the cart with the updated user" do
      existing_cart = Factory.insert(:cart)
      user_params = Factory.string_params_for(:user) |> Map.take(["name"])

      params = %{
        "user" => user_params
      }

      assert {:ok, %Cart{} = returned_cart} = ShoppingCart.update_user(existing_cart, params)

      cart_from_db = Repo.get(cart_with_user_and_order(), returned_cart.id)
      assert returned_cart == cart_from_db

      for {param_field, expected} <- user_params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_cart.user, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.user.inserted_at == cart_from_db.user.inserted_at
      refute existing_cart.user.updated_at == cart_from_db.user.updated_at
      assert %NaiveDateTime{} = cart_from_db.user.updated_at
    end

    test "success: it updates database when given a user and the updated user" do
      existing_cart = Factory.insert(:cart)
      params = Factory.string_params_for(:user) |> Map.take(["name"])

      assert {:ok, %User{} = returned_user} = ShoppingCart.update_user(existing_cart.user, params)

      user_from_db = Repo.get(User, returned_user.id)
      assert returned_user == user_from_db

      for {param_field, expected} <- params do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(returned_user, schema_field)

        assert actual == expected,
               "Values did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert existing_cart.user.inserted_at == user_from_db.inserted_at
      refute existing_cart.user.updated_at == user_from_db.updated_at
      assert %NaiveDateTime{} = user_from_db.updated_at
    end

    test "error: returns an error tuple when the cart's user can't be updated" do
      existing_cart = Factory.insert(:cart)

      bad_params = %{
        "user" => bad_user_params()
      }

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_user(existing_cart, bad_params)

      assert existing_cart == Repo.get(cart_with_user_and_order(), existing_cart.id)
    end

    test "error: returns an error tuple when a user can't be updated" do
      existing_cart = Factory.insert(:cart)

      bad_params = bad_user_params()

      assert {:error, %Changeset{valid?: false, errors: _errors}} =
               ShoppingCart.update_user(existing_cart.user, bad_params)

      assert existing_cart == Repo.get(cart_with_user_and_order(), existing_cart.id)
    end
  end

  # Delete Tests
  describe "delete_cart/1" do
    test "success: it deletes the cart" do
      cart = Factory.insert(:cart)

      assert {:ok, _deleted_cart} = ShoppingCart.delete_cart(cart)

      refute Repo.get(Cart, cart.id)
    end
  end

  describe "delete_billing_address/1" do
    test "success: it deletes the cart's billing address" do
      cart = Factory.insert(:cart)

      assert {:ok, _cart} = ShoppingCart.delete_billing_address(cart)

      assert Repo.get(Cart, cart.id)
    end
  end

  describe "delete_shipping_address/1" do
    test "success: it deletes the cart's shipping address" do
      cart = Factory.insert(:cart)

      assert {:ok, _cart} = ShoppingCart.delete_shipping_address(cart)

      assert Repo.get(Cart, cart.id)
    end
  end

  describe "delete_customer/1" do
    test "success: it deletes the cart's customer" do
      cart = Factory.insert(:cart)

      assert {:ok, _cart} = ShoppingCart.delete_customer(cart)

      assert Repo.get(Cart, cart.id)
    end
  end

  describe "delete_payment_method/1" do
    test "success: it deletes the cart's payment method" do
      cart = Factory.insert(:cart)

      assert {:ok, _cart} = ShoppingCart.delete_payment_method(cart)

      assert Repo.get(Cart, cart.id)
    end
  end

  describe "delete_order/1" do
    test "success: it deletes the order when passed the associated order's cart" do
      cart = Factory.insert(:cart)

      assert {:ok, _deleted_cart} = ShoppingCart.delete_order(cart)

      refute Repo.get(Order, cart.order.id)
    end

    test "success: it deletes the order when passed the order" do
      order = Factory.insert(:order)

      assert {:ok, _deleted_cart} = ShoppingCart.delete_order(order)

      refute Repo.get(Order, order.id)
    end
  end
end
