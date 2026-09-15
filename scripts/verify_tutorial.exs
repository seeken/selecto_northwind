alias SelectoNorthwind.{Repo, FilterSets}
alias SelectoNorthwind.SelectoDomains.{ProductDomain, OrderDomain}
base = System.get_env("TUTORIAL_URL", "http://localhost:4199")

for path <-
      ["/", "/tutorial", "/tutorial/postgrex", "/dev/dashboard", "/dev/dashboard/selecto"] ++
        for(
          name <- ~w(products customers orders employees),
          suffix <- ["", "/query-contract.json", "/query-guide.md"],
          do: "/#{name}_selecto#{suffix}"
        ) do
  response = Req.get!(base <> path)
  if response.status != 200, do: raise("#{path}: HTTP #{response.status}")
  IO.puts("PASS HTTP #{path}")
end

s =
  ProductDomain.domain()
  |> Selecto.configure(Repo, adapter: SelectoDBPostgreSQL.Adapter)
  |> Selecto.select(["id", "tags.name"])

{sql, _} = Selecto.to_sql(s)
unless sql =~ "product_tags" and not (sql =~ "tag_tags"), do: raise("Invalid tag join")
{:ok, {rows, _, _}} = Selecto.execute(s)
if rows == [], do: raise("No seeded products")
IO.puts("PASS tag join execution: #{length(rows)} rows")

s =
  OrderDomain.domain()
  |> Selecto.configure(Repo, adapter: SelectoDBPostgreSQL.Adapter)
  |> Selecto.join_parameterize(:customer, "USA", country: "USA")
  |> Selecto.select(["customer:USA.company_name"])

{:ok, {rows, _, _}} = Selecto.execute(s)
if rows == [], do: raise("No parameterized customer rows")
IO.puts("PASS parameterized join execution: #{length(rows)} rows")

{:error, :verification_complete} =
  Repo.transaction(fn ->
    ProductDomain.save_view("rerun-check", "/products_selecto", %{"view_mode" => "detail"})

    %{params: %{"view_mode" => "detail"}} =
      ProductDomain.get_view("rerun-check", "/products_selecto")

    {:ok, _} = ProductDomain.delete_view("rerun-check", "/products_selecto")

    {:ok, _} =
      ProductDomain.save_view_config(
        "rerun-check",
        "/products_selecto",
        "detail",
        %{"columns" => ["product_name"]}, user_id: "northwind-demo")

    %{params: %{"columns" => ["product_name"]}} =
      ProductDomain.get_view_config("rerun-check", "/products_selecto", "detail",
        user_id: "northwind-demo"
      )

    {:ok, _} =
      ProductDomain.delete_view_config("rerun-check", "/products_selecto", "detail",
        user_id: "northwind-demo"
      )

    {:ok, filter} =
      FilterSets.create_filter_set(%{
        name: "rerun-check",
        domain: "product",
        filters: %{"country" => "USA"},
        user_id: "northwind-demo"
      })

    [_ | _] = FilterSets.list_personal_filter_sets("northwind-demo", "product")
    {:ok, _} = FilterSets.delete_filter_set(filter.id, "northwind-demo")
    Repo.rollback(:verification_complete)
  end)

IO.puts("PASS saved views, column presets, and filter-set persistence (rolled back)")
