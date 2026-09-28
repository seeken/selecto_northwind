defmodule SelectoNorthwindWeb.ProductSearchLiveTest do
  use SelectoNorthwindWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  alias SelectoNorthwind.{ProductSearch, Repo}
  alias SelectoNorthwind.Catalog.{Category, Product, Supplier}

  setup do
    food = Repo.insert!(%Category{category_name: "Canned Food"})
    drink = Repo.insert!(%Category{category_name: "Canned Drink"})
    supplier = Repo.insert!(%Supplier{company_name: "Canned Supplier"})
    other = Repo.insert!(%Supplier{company_name: "Other Supplier"})

    products =
      for {name, category, source, price, hidden} <- [
            {"Canned Apple", food, supplier, "2.50", false},
            {"Canned Bread", food, other, "5.00", false},
            {"Canned Cola", drink, supplier, "3.00", false},
            {"Canned Hidden", drink, supplier, "1.00", true}
          ] do
        Repo.insert!(%Product{
          product_name: name,
          category_id: category.id,
          supplier_id: source.id,
          unit_price: Decimal.new(price),
          units_in_stock: 10,
          discontinued: hidden
        })
      end

    authorized =
      ProductSearch.authorize()
      |> Selecto.filter(Selecto.Expr.in("id", Enum.map(products, & &1.id)))

    %{
      food: food,
      drink: drink,
      supplier: supplier,
      other: other,
      products: products,
      authorized: authorized
    }
  end

  test "PostgreSQL counts exclude only the owned facet and preserve request scope", context do
    page = ProductSearch.page()

    input = %{
      "filters" => %{"category" => [context.food.id], "supplier" => [context.supplier.id]}
    }

    assert {:ok, result} = Selecto.CannedPage.run(page, context.authorized, input)
    assert result.total == 1
    assert length(result.rows) == 1
    assert Enum.at(hd(result.rows), 1) == "Canned Apple"

    assert Map.new(result.facets["category"].options, &{&1.value, &1.count}) == %{
             context.food.id => 1,
             context.drink.id => 1
           }

    assert Map.new(result.facets["supplier"].options, &{&1.value, &1.count}) == %{
             context.supplier.id => 1,
             context.other.id => 1
           }

    assert {:ok, ranged} =
             Selecto.CannedPage.run(page, context.authorized, %{
               "filters" => %{"price" => %{"min" => "3.00"}}
             })

    assert ranged.total == 2

    assert {:ok, aggregate} =
             Selecto.CannedPage.run(page, context.authorized, %{
               "view" => "categories",
               "limit" => 1,
               "filters" => %{}
             })

    assert aggregate.total == 3
    assert aggregate.result_total == 2
    assert aggregate.has_more

    assert {:ok, detail} =
             Selecto.CannedPage.run(page, context.authorized, %{
               "drilldown" => %{"view" => "categories", "values" => [context.food.category_name]}
             })

    assert detail.total == 2
  end

  test "selected zero values survive option search and bounded options", context do
    page = ProductSearch.page()

    controls =
      Enum.map(page.controls, fn
        %{id: "category"} = control -> %{control | limit: 1}
        control -> control
      end)

    page = %{page | controls: controls}

    assert {:ok, result} =
             Selecto.CannedPage.run(page, context.authorized, %{
               "filters" => %{"category" => [context.drink.id], "supplier" => [context.other.id]},
               "facet_search" => %{"category" => "Canned F"}
             })

    assert result.total == 0

    assert Enum.any?(
             result.facets["category"].options,
             &(&1.value == context.drink.id and &1.count == 0)
           )
  end

  test "related collections keep one root row and use the public subselect builder", context do
    product_domain = ProductSearch.domain()

    domain = %{
      name: "Categories with products",
      source:
        Map.put(product_domain.schemas.category, :associations, %{
          products: %{
            queryable: :products,
            field: :products,
            owner_key: :id,
            related_key: :category_id
          }
        }),
      schemas: %{products: Map.put(product_domain.source, :associations, %{})},
      joins: %{products: %{type: :left, cardinality: :many}}
    }

    base = Selecto.configure(domain, Repo, adapter: SelectoDBPostgreSQL.Adapter)

    query =
      base
      |> Selecto.select(["id", "category_name"])
      |> Selecto.subselect([
        %{
          target_schema: :products,
          fields: ["id", "product_name"],
          alias: "products",
          format: :json_agg
        }
      ])

    page =
      Selecto.CannedPage.new!(base,
        id: "categories",
        views: [%{id: "detail", kind: :detail, query: query}]
      )

    scoped = Selecto.filter(base, {"id", context.food.id})
    assert {:ok, result} = Selecto.CannedPage.run(page, scoped, %{})
    assert result.total == 1
    assert [[_id, "Canned Food", children]] = result.rows
    assert Enum.sort(Enum.map(children, & &1["product_name"])) == ["Canned Apple", "Canned Bread"]

    assert_raise ArgumentError, fn ->
      Selecto.CannedPage.new!(base,
        id: "bad",
        views: [
          %{
            id: "detail",
            kind: :detail,
            query: Selecto.select(base, ["id", "products.product_name"])
          }
        ]
      )
    end
  end

  test "LiveView uses Explorer results, applies controls, patches public state and drills down",
       %{conn: conn} do
    {:ok, view, _html} = live(conn, "/pages/products")
    assert has_element?(view, "#products[data-selecto-canned-page]")
    assert has_element?(view, "#products .sc-results .sc-table-wrap")
    assert has_element?(view, "#products .sc-results a[href^='/pages/products/']")
    refute has_element?(view, ".sc-builder-tabs")
    refute has_element?(view, "[phx-click=add-field]")

    view
    |> form("#products-controls", %{"view" => "categories", "filters" => %{"name" => "Canned"}})
    |> render_submit()

    assert_patch(view)
    assert has_element?(view, ".sc-results tr.is-drilldown")
    view |> element(".sc-results tr.is-drilldown", "Canned Food") |> render_click()
    assert_patch(view)
    assert has_element?(view, "#products [phx-click=clear-drilldown]")
    refute has_element?(view, ".sc-results tr.is-drilldown")
    assert has_element?(view, ".sc-results td", "Canned Apple")
    refute has_element?(view, ".sc-results td", "Canned Hidden")
    view |> element("#products [phx-click=clear]") |> render_click()
    assert_patch(view)
    refute has_element?(view, "#products [phx-click=clear-drilldown]")
  end

  test "record routes retain request scope after clearing", %{conn: conn, products: products} do
    product = hd(products)
    {:ok, view, _} = live(conn, "/pages/products/#{product.id}")
    assert has_element?(view, ".sc-results td", product.product_name)
    refute has_element?(view, ".sc-results td", "Canned Bread")
    view |> element("#products [phx-click=clear]") |> render_click()
    assert_patch(view)
    refute has_element?(view, ".sc-results td", "Canned Bread")
    hidden = List.last(products)
    {:ok, hidden_view, _} = live(conn, "/pages/products/#{hidden.id}")
    refute has_element?(hidden_view, ".sc-results td", hidden.product_name)
    assert has_element?(hidden_view, ".sc-results-empty")
  end
end
