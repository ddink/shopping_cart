defmodule ShoppingCart.Schemas.Schemas.PaymentMethodTest do
  use ShoppingCart.DataCase, async: true
  alias Ecto.Changeset
  alias ShoppingCart.Schemas.PaymentMethod

  describe "changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = Factory.string_params_for(:payment_method)

      assert_valid_changeset(params, payment_method_schema_fields(), &PaymentMethod.changeset/1)
    end

    test "error: returns an error changeset when given un-castable values" do
      params = bad_payment_method_params()

      assert_invalid_changeset(
        params,
        payment_method_schema_fields(),
        &PaymentMethod.changeset/1,
        :cast
      )
    end
  end

  describe "create_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = Factory.string_params_for(:payment_method)

      assert_valid_changeset(
        params,
        payment_method_schema_fields(),
        &PaymentMethod.create_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      params = bad_payment_method_params()

      changeset = PaymentMethod.create_changeset(params)

      assert %Changeset{
               valid?: false,
               errors: errors
             } = changeset

      assert_error_fields(errors, payment_method_schema_fields(), :cast)
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{"cc_token_id" => Faker.UUID.v4()}

      changeset = PaymentMethod.create_changeset(params)

      assert %Changeset{
               valid?: false,
               errors: errors
             } = changeset

      assert errors[:name], "expected an error for name"
      {_, meta} = errors[:name]

      assert meta[:validation] == :required,
             "The validation type, #{meta[:validation]}, is incorrect."
    end
  end
end
