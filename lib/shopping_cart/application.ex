defmodule ShoppingCart.Application do
  use Application

  def start(_type, _args) do
    children = [
      ShoppingCart.Repo
    ]

    opts = [strategy: :one_for_one, name: ShoppingCart.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
