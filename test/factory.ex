defmodule ShoppingCart.Factory do
  use ExMachina.Ecto, repo: StoreRepo.Repo

  alias ShoppingCart.Schemas.{
    Cart,
    Customer,
    BillingAddress,
    PaymentMethod,
    ShippingAddress,
    User
  }

  alias ShoppingCart.Schemas.Orders.Order

  @static_order_status Enum.random(Order.order_statuses())

  def empty_cart_no_order_factory do
    user = insert(:user)

    %Cart{
      cookie: Faker.UUID.v4(),
      browser_user_agent: Faker.Internet.UserAgent.desktop_user_agent(),
      language: Enum.random(["en", "es", "pt"]),
      billing_address: nil,
      customer: nil,
      order: nil,
      payment_method: nil,
      shipping_address: nil,
      user_id: user.id,
      inserted_at: NaiveDateTime.new!(~D[2010-01-13], ~T[23:00:07.005]),
      updated_at: NaiveDateTime.new!(~D[2010-01-13], ~T[23:00:07.005])
    }
  end

  def empty_cart_factory do
    user = insert(:user)

    %Cart{
      cookie: Faker.UUID.v4(),
      browser_user_agent: Faker.Internet.UserAgent.desktop_user_agent(),
      language: Enum.random(["en", "es", "pt"]),
      billing_address: nil,
      customer: nil,
      order: %{},
      payment_method: nil,
      shipping_address: nil,
      user_id: user.id,
      inserted_at: NaiveDateTime.new!(~D[2010-01-13], ~T[23:00:07.005]),
      updated_at: NaiveDateTime.new!(~D[2010-01-13], ~T[23:00:07.005])
    }
  end

  def cart_from_last_month_factory do
    order = order_factory()
    user = insert(:user)

    %Cart{
      cookie: Faker.UUID.v4(),
      browser_user_agent: Faker.Internet.UserAgent.desktop_user_agent(),
      language: Enum.random(["en", "es", "pt"]),
      billing_address: %{
        first_line: Faker.Address.street_address(),
        second_line: Faker.Address.secondary_address(),
        city: Faker.Address.city(),
        state: Faker.Address.state(),
        country: order.payment_country,
        postal_code: Faker.Address.postcode(),
        phone_number: Faker.Phone.EnUs.phone()
      },
      customer: %{
        first_name: Faker.Person.PtBr.first_name(),
        last_name: Faker.Person.PtBr.last_name(),
        email: Faker.Internet.email(),
        phone_number: Faker.Phone.EnUs.phone(),
        documentation_number: Faker.Address.country_code()
      },
      inserted_at: NaiveDateTime.new!(~D[2022-10-01], ~T[04:00:00.000]),
      updated_at: NaiveDateTime.new!(~D[2022-10-01], ~T[04:00:00.000]),
      order: order_from_last_month_factory(),
      payment_method: %{
        name: order.payment_method
      },
      shipping_address: %{
        first_line: Faker.Address.street_address(),
        second_line: Faker.Address.secondary_address(),
        city: Faker.Address.city(),
        state: Faker.Address.state(),
        country: Faker.Address.country_code(),
        postal_code: Faker.Address.postcode(),
        phone_number: Faker.Phone.EnUs.phone()
      },
      user_id: user.id,
      user: user
    }
  end

  def cart_factory do
    order = insert(:order)
    user = insert(:user)

    %Cart{
      cookie: Faker.UUID.v4(),
      browser_user_agent: Faker.Internet.UserAgent.desktop_user_agent(),
      language: Enum.random(["en", "es", "pt"]),
      billing_address: %{
        first_line: Faker.Address.street_address(),
        second_line: Faker.Address.secondary_address(),
        city: Faker.Address.city(),
        state: Faker.Address.state(),
        country: order.payment_country,
        postal_code: Faker.Address.postcode(),
        phone_number: Faker.Phone.EnUs.phone()
      },
      customer: %{
        first_name: Faker.Person.PtBr.first_name(),
        last_name: Faker.Person.PtBr.last_name(),
        email: Faker.Internet.email(),
        phone_number: Faker.Phone.EnUs.phone(),
        documentation_number: Faker.Address.country_code()
      },
      order: order,
      payment_method: %{
        name: order.payment_method
      },
      shipping_address: %{
        first_line: Faker.Address.street_address(),
        second_line: Faker.Address.secondary_address(),
        city: Faker.Address.city(),
        state: Faker.Address.state(),
        country: Faker.Address.country_code(),
        postal_code: Faker.Address.postcode(),
        phone_number: Faker.Phone.EnUs.phone()
      },
      user_id: user.id,
      user: user
    }
  end

  def cart_with_no_order_factory do
    order = insert(:order)
    user = insert(:user)

    %Cart{
      cookie: Faker.UUID.v4(),
      browser_user_agent: Faker.Internet.UserAgent.desktop_user_agent(),
      language: Enum.random(["en", "es", "pt"]),
      billing_address: %{
        first_line: Faker.Address.street_address(),
        second_line: Faker.Address.secondary_address(),
        city: Faker.Address.city(),
        state: Faker.Address.state(),
        country: order.payment_country,
        postal_code: Faker.Address.postcode(),
        phone_number: Faker.Phone.EnUs.phone()
      },
      customer: %{
        first_name: Faker.Person.PtBr.first_name(),
        last_name: Faker.Person.PtBr.last_name(),
        email: Faker.Internet.email(),
        phone_number: Faker.Phone.EnUs.phone(),
        documentation_number: Faker.Address.country_code()
      },
      order: nil,
      payment_method: %{
        name: order.payment_method
      },
      shipping_address: %{
        first_line: Faker.Address.street_address(),
        second_line: Faker.Address.secondary_address(),
        city: Faker.Address.city(),
        state: Faker.Address.state(),
        country: Faker.Address.country_code(),
        postal_code: Faker.Address.postcode(),
        phone_number: Faker.Phone.EnUs.phone()
      },
      user_id: user.id,
      user: user
    }
  end

  def customer_factory do
    %Customer{
      first_name: Faker.Person.PtBr.first_name(),
      last_name: Faker.Person.PtBr.last_name(),
      email: Faker.Internet.email(),
      phone_number: Faker.Phone.EnUs.phone(),
      documentation_number: Faker.Address.country_code()
    }
  end

  def billing_address_factory do
    order = order_factory()

    %BillingAddress{
      first_line: Faker.Address.street_address(),
      second_line: Faker.Address.secondary_address(),
      city: Faker.Address.city(),
      state: Faker.Address.state(),
      country: order.payment_country,
      postal_code: Faker.Address.postcode(),
      phone_number: Faker.Phone.EnUs.phone()
    }
  end

  def shipping_address_factory do
    order = order_factory()

    %ShippingAddress{
      first_line: Faker.Address.street_address(),
      second_line: Faker.Address.secondary_address(),
      city: Faker.Address.city(),
      state: Faker.Address.state(),
      country: order.payment_country,
      postal_code: Faker.Address.postcode(),
      phone_number: Faker.Phone.EnUs.phone()
    }
  end

  def order_factory do
    order_price = Enum.random(20_000..1_000_000)
    tax_price = (order_price * 0.19) |> floor
    payment_method = Enum.random(["EFECTY", "PSE", "BANK_REFERENCED"])
    country_code = Faker.Address.country_code()

    %Order{
      total_transaction_price: order_price + tax_price,
      tax_price: tax_price,
      order_price: order_price,
      currency: Enum.random(["COP", "ARS", "BRL", "CLP", "MXN", "PEN", "USD"]),
      payment_installments: Enum.random(1..8),
      payment_method: payment_method,
      payment_country: country_code,
      skus: %{
        Faker.Address.country_code() => to_string(Enum.random(1..5))
      },
      status: Enum.random(Order.order_statuses())
    }
  end

  def static_value_order_factory do
    order_price = Enum.random(20_000..1_000_000)
    tax_price = (order_price * 0.19) |> floor

    %Order{
      total_transaction_price: order_price + tax_price,
      tax_price: tax_price,
      order_price: order_price,
      currency: "GBP",
      payment_installments: 10,
      payment_method: "Credit Card",
      payment_country: "HK",
      skus: %{
        Faker.Address.country_code() => to_string(Enum.random(1..5))
      },
      status: @static_order_status
    }
  end

  def order_from_last_month_factory do
    order_price = Enum.random(20_000..1_000_000)
    tax_price = (order_price * 0.19) |> floor
    payment_method = Enum.random(["EFECTY", "PSE", "BANK_REFERENCED"])
    country_code = Faker.Address.country_code()

    %Order{
      total_transaction_price: order_price + tax_price,
      tax_price: tax_price,
      order_price: order_price,
      currency: Enum.random(["COP", "ARS", "BRL", "CLP", "MXN", "PEN", "USD"]),
      payment_installments: Enum.random(1..8),
      payment_method: payment_method,
      payment_country: country_code,
      skus: %{
        Faker.Address.country_code() => to_string(Enum.random(1..5))
      },
      status: Enum.random(Order.order_statuses()),
      inserted_at: NaiveDateTime.new!(~D[2022-10-01], ~T[04:00:00.000]),
      updated_at: NaiveDateTime.new!(~D[2022-10-01], ~T[04:00:00.000])
    }
  end

  def order_with_cart_id_factory do
    order_price = Enum.random(20_000..1_000_000)
    tax_price = (order_price * 0.19) |> floor
    payment_method = Enum.random(["EFECTY", "PSE", "BANK_REFERENCED"])
    country_code = Faker.Address.country_code()
    cart = insert(:empty_cart_no_order)

    %Order{
      total_transaction_price: order_price + tax_price,
      tax_price: tax_price,
      order_price: order_price,
      currency: Enum.random(["COP", "ARS", "BRL", "CLP", "MXN", "PEN", "USD"]),
      payment_installments: Enum.random(1..8),
      payment_method: payment_method,
      payment_country: country_code,
      skus: %{
        Faker.Address.country_code() => to_string(Enum.random(1..5))
      },
      status: Enum.random(Order.order_statuses()),
      cart_id: cart.id
    }
  end

  def payment_method_factory do
    order = order_factory()

    %PaymentMethod{
      name: order.payment_method,
      cc_token_id: Faker.UUID.v4()
    }
  end

  def user_factory do
    %User{
      name: Faker.Person.PtBr.name(),
      inserted_at: NaiveDateTime.new!(~D[2022-10-01], ~T[04:00:00.000]),
      updated_at: NaiveDateTime.new!(~D[2022-10-01], ~T[04:00:00.000])
    }
  end
end
