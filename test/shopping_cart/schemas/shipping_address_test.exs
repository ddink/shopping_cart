defmodule ShoppingCart.ShippingAddressTest do
  use ShoppingCart.DataCase, async: true
  alias Ecto.Changeset
  alias ShoppingCart.Schemas.ShippingAddress, as: Address

  describe "changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = Factory.string_params_for(:shipping_address)

      assert_valid_changeset(params, address_schema_fields(), &Address.changeset/1)
    end

    test "error: returns an error changeset when given un-castable values" do
      params = bad_address_params()

      assert_invalid_changeset(
        params,
        address_schema_fields(),
        &Address.changeset/1,
        :cast
      )
    end
  end

  describe "create_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = Factory.string_params_for(:shipping_address)

      assert_valid_changeset(params, address_schema_fields(), &Address.create_changeset/1)
    end

    test "error: returns an error changeset when given un-castable values" do
      params = bad_address_params()

      changeset = Address.create_changeset(params)

      assert %Changeset{
               valid?: false,
               errors: errors
             } = changeset

      assert_error_fields(errors, address_schema_fields(), :cast)
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert_invalid_changeset(
        params,
        address_schema_fields(),
        &Address.create_changeset/1,
        :required
      )
    end
  end
end
