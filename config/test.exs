import Config

config :shopping_cart, ShoppingCart.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "shopping_cart_db_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :logger, :console, level: :warn
