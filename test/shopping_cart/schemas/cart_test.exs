defmodule ShoppingCart.Schemas.CartTest do
  use ShoppingCart.DataCase, async: true
  alias Ecto.Changeset
  alias ShoppingCart.Schemas.Cart

  describe "changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = Factory.string_params_for(:cart_with_no_order)

      changeset = Cart.changeset(params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for field <- schema_fields() do
        schema_field = Atom.to_string(field)

        actual =
          case Map.get(changes, schema_field) do
            %Ecto.Changeset{changes: changes} ->
              changes

            _ = changes ->
              changes
          end

        expected = params[field]

        assert actual == expected,
               "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = bad_cart_params()

      changeset = Cart.changeset(bad_params)

      assert %Changeset{valid?: false, errors: errors} = changeset

      for field <- schema_fields() do
        assert errors[field], "expected an error for #{field}"
        {_, meta} = errors[field]

        assert Enum.member?([:cast, :embed, :assoc], meta[:validation]),
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end

    test "error: returns an error changeset with inclusion validation error
					when given un-castable value for language" do
      bad_params = %{
        "cookie" => Faker.UUID.v4(),
        "browser_user_agent" => Faker.Internet.UserAgent.desktop_user_agent(),
        "language" => "fr"
      }

      changeset = Cart.changeset(bad_params)

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert errors[:language], "expected an error for language"
      {_, meta} = errors[:language]

      assert meta[:validation] == :inclusion,
             "The validation type, #{meta[:validation]}, is incorrect."
    end
  end

  describe "create_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = Factory.string_params_for(:cart_with_no_order)

      changeset = Cart.create_changeset(params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for field <- schema_fields() do
        schema_field = Atom.to_string(field)

        actual =
          case Map.get(changes, schema_field) do
            %Ecto.Changeset{changes: changes} ->
              changes

            _ = changes ->
              changes
          end

        expected = params[field]

        assert actual == expected,
               "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = bad_cart_params()

      changeset = Cart.create_changeset(bad_params)

      assert %Changeset{valid?: false, errors: errors} = changeset

      for field <- schema_fields() do
        assert errors[field], "expected an error for #{field}"
        {_, meta} = errors[field]

        assert Enum.member?([:cast, :embed, :assoc], meta[:validation]),
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end

    test "error: returns an error changeset with required validation error
					when missing required fields" do
      changeset = Cart.create_changeset(%{})

      assert %Changeset{valid?: false, errors: errors} = changeset

      assert_error_fields(errors, required_fields(), :required)
    end
  end

  describe "create_order_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "order" => Factory.string_params_for(:order_with_cart_id)
      }

      assert_valid_embedded_changeset(
        params,
        order_schema_fields(:string),
        &Cart.create_order_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "order" => bad_order_params()
      }

      changeset = Cart.create_order_changeset(bad_params)

      assert %Changeset{
               valid?: false,
               changes: %{
                 order: %Changeset{
                   errors: errors
                 }
               }
             } = changeset

      for field <- order_schema_fields() do
        assert errors[field], "expected an error for #{field}"
        {_, meta} = errors[field]

        assert meta[:validation] == :cast,
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end
  end

  describe "update_order_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "order" => Factory.string_params_for(:order_with_cart_id)
      }

      assert_valid_embedded_changeset(
        params,
        order_schema_fields(),
        &Cart.update_order_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "order" => bad_order_params()
      }

      assert_invalid_order_changeset(
        bad_params,
        order_schema_fields(),
        &Cart.update_order_changeset/1,
        :cast
      )
    end
  end

  describe "update_order_skus_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      skus_params =
        Factory.string_params_for(:order)
        |> Map.take(order_skus_required_fields())

      params = %{
        "order" => skus_params
      }

      assert_valid_embedded_changeset(
        params,
        skus_required_schema_fields(),
        &Cart.update_order_skus_changeset/1
      )
    end

    test "error: returns an error changeset when required fields are missing" do
      bad_skus_params =
        Factory.string_params_for(:order)
        |> Map.drop(order_skus_required_fields())

      bad_params = %{
        "order" => bad_skus_params
      }

      assert_invalid_order_changeset(
        bad_params,
        skus_required_schema_fields(),
        &Cart.update_order_skus_changeset/1,
        :required
      )
    end
  end

  describe "create_shipping_address_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "shipping_address" => Factory.string_params_for(:shipping_address)
      }

      assert_valid_embedded_changeset(
        params,
        address_schema_fields(),
        &Cart.create_shipping_address_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "shipping_address" => bad_address_params()
      }

      changeset = Cart.create_shipping_address_changeset(bad_params)

      assert %Changeset{
               valid?: false,
               changes: %{
                 shipping_address: %Changeset{
                   errors: errors
                 }
               }
             } = changeset

      assert_error_fields(errors, address_schema_fields(), :cast)
    end
  end

  describe "update_shipping_address_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "shipping_address" => Factory.string_params_for(:shipping_address)
      }

      assert_valid_embedded_changeset(
        params,
        address_schema_fields(),
        &Cart.update_shipping_address_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "shipping_address" => bad_address_params()
      }

      changeset = Cart.update_shipping_address_changeset(bad_params)

      assert %Changeset{
               valid?: false,
               changes: %{
                 shipping_address: %Changeset{
                   errors: errors
                 }
               }
             } = changeset

      assert_error_fields(errors, address_schema_fields(), :cast)
    end
  end

  describe "create_billing_address_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "billing_address" => Factory.string_params_for(:billing_address)
      }

      assert_valid_embedded_changeset(
        params,
        address_schema_fields(),
        &Cart.create_billing_address_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "billing_address" => bad_address_params()
      }

      changeset = Cart.create_billing_address_changeset(bad_params)

      assert %Changeset{
               valid?: false,
               changes: %{
                 billing_address: %Changeset{
                   errors: errors
                 }
               }
             } = changeset

      assert_error_fields(errors, address_schema_fields(), :cast)
    end
  end

  describe "update_billing_address_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "billing_address" => Factory.string_params_for(:billing_address)
      }

      assert_valid_embedded_changeset(
        params,
        address_schema_fields(),
        &Cart.update_billing_address_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "billing_address" => bad_address_params()
      }

      changeset = Cart.update_billing_address_changeset(bad_params)

      assert %Changeset{
               valid?: false,
               changes: %{
                 billing_address: %Changeset{
                   errors: errors
                 }
               }
             } = changeset

      assert_error_fields(errors, address_schema_fields(), :cast)
    end
  end

  describe "create_customer_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "customer" => Factory.string_params_for(:customer)
      }

      assert_valid_embedded_changeset(
        params,
        customer_schema_fields(),
        &Cart.create_customer_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "customer" => bad_customer_params()
      }

      changeset = Cart.create_customer_changeset(bad_params)

      assert %Changeset{
               valid?: false,
               changes: %{
                 customer: %Changeset{
                   errors: errors
                 }
               }
             } = changeset

      assert_error_fields(errors, customer_schema_fields(), :cast)
    end
  end

  describe "update_customer_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "customer" => Factory.string_params_for(:customer)
      }

      assert_valid_embedded_changeset(
        params,
        customer_schema_fields(),
        &Cart.update_customer_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "customer" => bad_customer_params()
      }

      changeset = Cart.update_customer_changeset(bad_params)

      assert %Changeset{
               valid?: false,
               changes: %{
                 customer: %Changeset{
                   errors: errors
                 }
               }
             } = changeset

      assert_error_fields(errors, customer_schema_fields(), :cast)
    end
  end

  describe "create_payment_method_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "payment_method" => Factory.string_params_for(:payment_method)
      }

      assert_valid_embedded_changeset(
        params,
        payment_method_schema_fields(),
        &Cart.create_payment_method_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "payment_method" => bad_payment_method_params()
      }

      changeset = Cart.create_payment_method_changeset(bad_params)

      assert %Changeset{
               valid?: false,
               changes: %{
                 payment_method: %Changeset{
                   errors: errors
                 }
               }
             } = changeset

      assert_error_fields(errors, payment_method_schema_fields(), :cast)
    end
  end

  describe "update_payment_method_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "payment_method" => Factory.string_params_for(:payment_method)
      }

      assert_valid_embedded_changeset(
        params,
        payment_method_schema_fields(),
        &Cart.update_payment_method_changeset/1
      )
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "payment_method" => bad_payment_method_params()
      }

      changeset = Cart.update_payment_method_changeset(bad_params)

      assert %Changeset{
               valid?: false,
               changes: %{
                 payment_method: %Changeset{
                   errors: errors
                 }
               }
             } = changeset

      assert_error_fields(errors, payment_method_schema_fields(), :cast)
    end
  end

  describe "update_user_changeset/1" do
    test "success: returns a valid changeset when given valid arguments" do
      params = %{
        "user" => %{
          # don't forget to add after migration
          # default_token_id: Faker.UUID.v4(),
          "first_name" => Faker.Person.PtBr.name()
        }
      }

      assert_valid_changeset(params, user_schema_fields(), &Cart.update_user_changeset/1)
    end

    test "error: returns an error changeset when given un-castable values" do
      bad_params = %{
        "user" => bad_user_params()
      }

      changeset = Cart.update_user_changeset(bad_params)

      assert %Changeset{
               valid?: false,
               changes: %{
                 user: %Changeset{
                   errors: errors
                 }
               }
             } = changeset

      assert_error_fields(errors, user_schema_fields(), :cast)
    end
  end

  defp assert_invalid_order_changeset(params, fields, changeset_fn, validation_type)
       when is_list(fields) do
    changeset = changeset_fn.(params)

    assert %Changeset{
             valid?: false,
             changes: %{
               order: %Changeset{
                 errors: errors
               }
             }
           } = changeset

    assert_error_fields(errors, fields, validation_type)
  end
end
