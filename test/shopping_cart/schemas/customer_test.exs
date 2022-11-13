defmodule ShoppingCart.Schemas.CustomerTest do
  use ShoppingCart.DataCase, async: true
  alias Ecto.Changeset
  alias ShoppingCart.Schemas.Customer

  describe "changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = Factory.string_params_for(:customer)

      assert_valid_changeset(params, customer_schema_fields(), &Customer.changeset/1)
    end

    test "error: returns an error changeset when given un-castable values" do
      params = bad_customer_params()

      assert_invalid_changeset(
        params,
        customer_schema_fields(),
        &Customer.changeset/1,
        :cast
      )
    end
  end

  describe "create_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = Factory.string_params_for(:customer)

      assert_valid_changeset(params, customer_schema_fields(), &Customer.create_changeset/1)
    end

    test "error: returns an error changeset when given un-castable values" do
      params = bad_customer_params()

      changeset = Customer.create_changeset(params)

      assert %Changeset{
               valid?: false,
               errors: errors
             } = changeset

      assert_error_fields(errors, customer_schema_fields(), :cast)
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert_invalid_changeset(
        params,
        customer_schema_fields(),
        &Customer.create_changeset/1,
        :required
      )
    end
  end
end
