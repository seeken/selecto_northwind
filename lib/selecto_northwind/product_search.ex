defmodule SelectoNorthwind.ProductSearch do
  @moduledoc "An authored product search with shared category and supplier facets."
  alias Selecto.Expr, as: X

  def base do
    Selecto.configure(
      domain(),
      SelectoNorthwind.Repo,
      adapter: SelectoDBPostgreSQL.Adapter
    )
  end

  def domain do
    %{
      name: "Product search",
      source:
        Map.put(
          schema("products",
            id: :integer,
            product_name: :string,
            category_id: :integer,
            supplier_id: :integer,
            unit_price: :decimal,
            units_in_stock: :integer,
            discontinued: :boolean
          ),
          :associations,
          %{
            category: %{
              queryable: :category,
              field: :category,
              owner_key: :category_id,
              related_key: :id
            },
            supplier: %{
              queryable: :supplier,
              field: :supplier,
              owner_key: :supplier_id,
              related_key: :id
            }
          }
        ),
      schemas: %{
        category: schema("categories", id: :integer, category_name: :string),
        supplier: schema("suppliers", id: :integer, company_name: :string)
      },
      joins: %{
        category: %{type: :left, cardinality: :one},
        supplier: %{type: :left, cardinality: :one}
      }
    }
  end

  defp schema(table, fields) do
    %{
      source_table: table,
      primary_key: :id,
      fields: Keyword.keys(fields),
      columns: Map.new(fields, fn {key, type} -> {key, %{type: type}} end),
      redact_fields: [],
      associations: %{}
    }
  end

  # This public demo's request policy excludes discontinued products. A private
  # application resolves the current user's tenant/permissions here on each run.
  def authorize, do: Selecto.filter(base(), X.eq("discontinued", false))

  def page do
    query = base()

    Selecto.CannedPage.new!(query,
      id: "products",
      views: [
        %{
          id: "detail",
          label: "Products",
          kind: :detail,
          query:
            Selecto.select(query, [
              "id",
              "product_name",
              "category.category_name",
              "supplier.company_name",
              "unit_price",
              "units_in_stock"
            ])
        },
        %{
          id: "categories",
          label: "By category",
          kind: :aggregate,
          query:
            query
            |> Selecto.select([
              "category.category_name",
              X.as(X.count_distinct("id"), "Products")
            ])
            |> Selecto.group_by(["category.category_name"])
        }
      ],
      controls: [
        %{
          id: "category",
          label: "Category",
          kind: :facet,
          field: "category_id",
          label_field: "category.category_name",
          searchable: true
        },
        %{
          id: "supplier",
          label: "Supplier",
          kind: :facet,
          field: "supplier_id",
          label_field: "supplier.company_name",
          searchable: true
        },
        %{id: "price", label: "Unit price", kind: :range, field: "unit_price"},
        %{id: "name", label: "Product name starts with", kind: :text, field: "product_name"}
      ]
    )
  end
end
