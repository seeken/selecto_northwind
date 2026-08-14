defmodule SelectoNorthwindWeb.TutorialControllerTest do
  use SelectoNorthwindWeb.ConnCase

  test "GET /tutorial links to the Postgrex tutorial", %{conn: conn} do
    conn = get(conn, ~p"/tutorial")
    response = html_response(conn, 200)

    assert response =~ ~s(href="/tutorial/postgrex")
    assert response =~ ~s({:selecto, "~> 0.4.8"})
    assert response =~ ~s({:selecto_db_postgresql, "~> 0.4.5"})
    assert response =~ ~s({:selecto_components, "~> 0.4.9"})
    assert response =~ ~s({:selecto_mix, "~> 0.4.7")
    assert response =~ "config :selecto_northwind, :selecto_adapter, SelectoDBPostgreSQL.Adapter"

    assert response =~
             "Selecto.configure(Repo, adapter: SelectoDBPostgreSQL.Adapter)"

    refute response =~ "Selecto.configure(Repo)"
  end

  test "GET /tutorial/postgrex renders the non-Ecto walkthrough", %{conn: conn} do
    conn = get(conn, ~p"/tutorial/postgrex")
    response = html_response(conn, 200)

    assert response =~ "Selecto without Ecto Schemas"
    assert response =~ "mix selecto.gen.domain"
    assert response =~ "mix selecto.setup"
    assert response =~ ~s({:selecto, "~> 0.4.8"})
    assert response =~ ~s({:selecto_db_postgresql, "~> 0.4.5"})
    assert response =~ ~s({:selecto_components, "~> 0.4.9"})
    assert response =~ ~s({:selecto_mix, "~> 0.4.7")

    assert response =~
             "Selecto.configure(domain, SelectoNorthwind.Database, adapter: SelectoDBPostgreSQL.Adapter)"

    refute response =~ "Selecto.configure(domain, SelectoNorthwind.Database)"
    refute response =~ "selecto_postgrex_mix"
  end
end
