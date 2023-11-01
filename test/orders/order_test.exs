defmodule ShoppingCart.Schemas.Orders.OrderTest do
  use ShoppingCart.DataCase, async: true
  alias Ecto.Changeset
  alias ShoppingCart.Schemas.Orders.Order

  describe "changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = Factory.string_params_for(:order_with_cart_id)

      assert_valid_changeset(params, order_schema_fields(), &Order.changeset/1)
    end

    test "error: returns an error changeset when given un-castable values" do
      params = bad_order_params()

      assert_invalid_changeset(params, order_schema_fields(), &Order.changeset/1, :cast)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when fields required to create an order are missing" do
      order = Factory.insert(:order)

      params =
        Factory.string_params_for(:static_value_order)
        |> Map.take([
          "currency",
          "payment_installments",
          "payment_method",
          "payment_country",
          "status"
        ])

      changeset = Order.changeset(order, params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      fields = [
        "currency",
        "payment_installments",
        "payment_method",
        "payment_country",
        "status"
      ]

      params = atom_map(params)

      for field <- fields do
        actual = Map.get(changes, field)
        expected = params[field]

        assert actual == expected,
               "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error changeset when status values passed as param is not one of the pre-determined order status values" do
      params = %{
        "status" => "status"
      }

      changeset = Order.changeset(%Order{}, params)

      assert %Changeset{
               valid?: false,
               errors: errors
             } = changeset

      assert errors[:status], "expected an error for status"
      {_, meta} = errors[:status]

      assert meta[:validation] == :inclusion,
             "The validation type, #{meta[:validation]}, is incorrect."
    end
  end

  describe "create_changeset/1" do
    test "success: returns a valid changeset when optional fields are missing from params" do
      params =
        Factory.string_params_for(:order_with_cart_id)
        |> Map.take([
          "total_transaction_price",
          "tax_price",
          "order_price",
          "skus",
          "cart_id"
        ])

      # status is pre-populated when using create_changeset
      # so we'll check it with an assertion against the changeset
      fields = order_schema_fields() -- [:status]
      assert_valid_changeset(params, fields, &Order.create_changeset/1)

      changeset = Order.create_changeset(params)

      assert %Changeset{
               valid?: true,
               changes: %{
                 status: "pre_checkout"
               }
             } = changeset
    end

    test "error: returns an error changeset when required fields are missing" do
      params =
        Factory.string_params_for(:order)
        |> Map.take([
          "currency",
          "payment_installments",
          "payment_method",
          "payment_country",
          "status"
        ])

      assert_invalid_changeset(
        params,
        order_required_schema_fields(),
        &Order.create_changeset/1,
        :required
      )
    end
  end

  describe "create_changeset/2" do
    test "success: sets change that gives order status of pre_checkout" do
      params =
        Factory.string_params_for(:order_with_cart_id)
        |> Map.take([
          "total_transaction_price",
          "tax_price",
          "order_price",
          "skus",
          "cart_id"
        ])

      changeset = Order.create_changeset(%Order{}, params)

      assert %Changeset{
               valid?: true,
               changes: %{
                 status: "pre_checkout"
               }
             } = changeset
    end

    test "error: returns an error changeset when given un-castable values" do
      params = bad_order_params()

      changeset = Order.create_changeset(%Order{}, params)

      assert %Changeset{
               valid?: false,
               errors: errors
             } = changeset

      assert_error_fields(errors, order_required_schema_fields(), :cast)
    end
  end

  describe "update_skus_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params =
        Factory.string_params_for(:order)
        |> Map.take([
          "total_transaction_price",
          "tax_price",
          "order_price",
          "skus"
        ])

      assert_valid_changeset(
        params,
        skus_required_schema_fields(),
        &Order.update_skus_changeset/1
      )
    end

    test "error: returns an error changeset when required fields are missing" do
      params =
        Factory.string_params_for(:order)
        |> Map.take([
          "currency",
          "payment_installments",
          "payment_method",
          "payment_country",
          "status"
        ])

      assert_invalid_changeset(
        params,
        skus_required_schema_fields(),
        &Order.update_skus_changeset/1,
        :required
      )
    end
  end

  describe "delete_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      assert %Changeset{valid?: true} = Order.delete_changeset(%Order{})
    end
  end
end
