defmodule SelectoNorthwindWeb.PageController do
  use SelectoNorthwindWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def customers_selecto(conn, _params) do
    conn
    |> put_flash(:info, "Customers Selecto section is not available yet.")
    |> render(:coming_soon, page_title: "Customers")
  end

  def products_selecto(conn, _params) do
    conn
    |> put_flash(:info, "Products Selecto section is not available yet.")
    |> render(:coming_soon, page_title: "Products")
  end

  def orders_selecto(conn, _params) do
    conn
    |> put_flash(:info, "Orders Selecto section is not available yet.")
    |> render(:coming_soon, page_title: "Orders")
  end

  def analytics(conn, _params) do
    conn
    |> put_flash(:info, "Analytics section is not available yet.")
    |> render(:coming_soon, page_title: "Analytics")
  end
end
