defmodule SelectoNorthwindWeb.TutorialControllerTest do
  use SelectoNorthwindWeb.ConnCase

  test "GET /tutorial links to the Postgrex tutorial", %{conn: conn} do
    conn = get(conn, ~p"/tutorial")

    assert html_response(conn, 200) =~ ~s(href="/tutorial/postgrex")
  end

  test "GET /tutorial/postgrex renders the non-Ecto walkthrough", %{conn: conn} do
    conn = get(conn, ~p"/tutorial/postgrex")
    response = html_response(conn, 200)

    assert response =~ "Selecto without Ecto Schemas"
    assert response =~ "mix selecto.gen.domain"
    assert response =~ "mix selecto.setup"
    refute response =~ "selecto_postgrex_mix"
  end
end
