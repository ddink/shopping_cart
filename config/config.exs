import Config

config :shopping_cart, ecto_repos: [ShoppingCart.Repo]

config :shopping_cart, ShoppingCart.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "shopping_cart_db",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

import_config("#{Mix.env()}.exs")
