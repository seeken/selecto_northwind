defmodule SelectoNorthwind.Repo do
  use Ecto.Repo,
    otp_app: :selecto_northwind,
    adapter: Ecto.Adapters.Postgres
end
