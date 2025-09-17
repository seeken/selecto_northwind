defmodule SelectoNorthwind.SelectoDomains.ProductDomain do

  use SelectoNorthwind.SavedViewContext

  @moduledoc """
  Selecto domain configuration for SelectoNorthwind.Catalog.Product.

  This file was automatically generated from the Ecto schema.
  You can customize this configuration by modifying the domain map below.

  ## Usage

      # Basic usage
      selecto = Selecto.configure(SelectoNorthwind.SelectoDomains.ProductDomain.domain(), MyApp.Repo)

      # With Ecto integration
      selecto = Selecto.from_ecto(MyApp.Repo, SelectoNorthwind.Catalog.Product)

      # Execute queries
      {:ok, {rows, columns, aliases}} = Selecto.execute(selecto)

  ## Customization

  You can customize this domain by:
  - Adding custom fields to the fields list
  - Modifying default selections and filters
  - Adjusting join configurations
  - Adding parameterized joins with dynamic parameters
  - Configuring subfilters for relationship-based filtering (Selecto 0.3.0+)
  - Setting up window functions for advanced analytics (Selecto 0.3.0+)
  - Defining pivot table configurations (Selecto 0.3.0+)
  - Customizing pagination settings with LIMIT/OFFSET support
  - Adding custom domain metadata

  Fields, filters, and joins marked with "# CUSTOM" comments will be
  preserved when this file is regenerated.

  ## Parameterized Joins

  This domain supports parameterized joins that accept runtime parameters:

  ```elixir
  joins: %{
    products: %{
      type: :left,
      name: "Products",
      parameters: [
        %{name: :category, type: :string, required: true},
        %{name: :active, type: :boolean, required: false, default: true}
      ],
      fields: %{
        name: %{type: :string},
        price: %{type: :decimal}
      }
    }
  }
  ```

  Use dot notation to reference parameterized fields:
  - `products:electronics.name` - Products in electronics category
  - `products:electronics:true.price` - Active products in electronics

  ## Regeneration

  To regenerate this file after schema changes:

      mix selecto.gen.domain SelectoNorthwind.Catalog.Product

  Additional options:

      # Force regenerate (overwrites customizations)
      mix selecto.gen.domain SelectoNorthwind.Catalog.Product --force

      # Preview changes without writing files
      mix selecto.gen.domain SelectoNorthwind.Catalog.Product --dry-run

      # Include associations as joins
      mix selecto.gen.domain SelectoNorthwind.Catalog.Product --include-associations

      # Generate with LiveView files
      mix selecto.gen.domain SelectoNorthwind.Catalog.Product --live

      # Generate with saved views support
      mix selecto.gen.domain SelectoNorthwind.Catalog.Product --live --saved-views

      # Expand specific associated schemas with full columns/associations
      mix selecto.gen.domain SelectoNorthwind.Catalog.Product --expand-schemas categories,tags

  Your customizations will be preserved during regeneration (unless --force is used).
  """

  @doc """
  Returns the Selecto domain configuration for SelectoNorthwind.Catalog.Product.
  """
  def domain do
    %{
      # Generated from schema: Elixir.SelectoNorthwind.Catalog.Product
      # Last updated: 2025-09-17T19:58:58.797413Z

      source: %{
        source_table: "products",
        primary_key: :id,

        # Available fields from schema
        # NOTE: This is redundant with columns - consider using Map.keys(columns) instead
        fields: [
          :id,
          :product_name,
          :quantity_per_unit,
          :unit_price,
          :units_in_stock,
          :units_on_order,
          :reorder_level,
          :discontinued,
          :supplier_id,
          :category_id,
          :inserted_at,
          :updated_at
        ],

        # Fields to exclude from queries
        redact_fields: [],

        # Field type definitions (contains the same info as fields above)
        columns: %{
          :id => %{type: :integer},
          :product_name => %{type: :string},
          :quantity_per_unit => %{type: :string},
          :unit_price => %{type: :decimal},
          :units_in_stock => %{type: :integer},
          :units_on_order => %{type: :integer},
          :reorder_level => %{type: :integer},
          :discontinued => %{type: :boolean},
          :supplier_id => %{type: :integer},
          :category_id => %{type: :integer},
          :inserted_at => %{type: :naive_datetime},
          :updated_at => %{type: :naive_datetime}
        },

        # Schema associations
        associations: %{
          :category => %{
            queryable: :category,
            field: :category,
            owner_key: :category_id,
            related_key: :id
          },
          :supplier => %{
            queryable: :supplier,
            field: :supplier,
            owner_key: :supplier_id,
            related_key: :id
          },
          :order_details => %{
            queryable: :order_detail,
            field: :order_details,
            owner_key: :id,
            related_key: :product_id
          }
        }
      },
      schemas: %{
        :category => %{
          # Expanded schema configuration for SelectoNorthwind.Catalog.Category
          source_table: "categories",
          primary_key: :id,
          fields: [:id, :category_name, :description, :picture, :inserted_at, :updated_at],
          redact_fields: [],
          columns: %{
            :id => %{type: :integer},
            :description => %{type: :string},
            :category_name => %{type: :string},
            :picture => %{type: :binary},
            :inserted_at => %{type: :naive_datetime},
            :updated_at => %{type: :naive_datetime}
          },
          associations: %{}
        },
        :supplier => %{
          # TODO: Add proper schema configuration for SelectoNorthwind.Catalog.Supplier
          # This will be auto-generated when you run:
          # mix selecto.gen.domain SelectoNorthwind.Catalog.Supplier
          # Or use --expand-schemas supplier to expand automatically
          source_table: "suppliers",
          primary_key: :id,
          # Add fields for SelectoNorthwind.Catalog.Supplier
          fields: [],
          redact_fields: [],
          columns: %{},
          associations: %{}
        },
        :order_detail => %{
          # TODO: Add proper schema configuration for SelectoNorthwind.Sales.OrderDetail
          # This will be auto-generated when you run:
          # mix selecto.gen.domain SelectoNorthwind.Sales.OrderDetail
          # Or use --expand-schemas order_detail to expand automatically
          source_table: "order_details",
          primary_key: :id,
          # Add fields for SelectoNorthwind.Sales.OrderDetail
          fields: [],
          redact_fields: [],
          columns: %{},
          associations: %{}
        }
      },
      name: "Product Domain",

      # Default selections (customize as needed)
      default_selected: ["id", "product_name", "supplier_id", "category_id"],

      # Suggested filters (add/remove as needed)
      filters: %{
        "category_id" => %{name: "Category Id", type: :integer},
        "discontinued" => %{default: true, name: "Discontinued", type: :boolean}
      },

      # Subfilters for relationship-based filtering (Selecto 0.3.0+)
      subfilters: %{},

      # Window functions configuration (Selecto 0.3.0+)
      window_functions: %{},

      # Query pagination settings
      pagination: %{
        # Default pagination settings
        default_limit: 50,
        max_limit: 1000,

        # Cursor-based pagination support
        cursor_fields: [:id],

        # Enable/disable pagination features
        allow_offset: true,
        require_limit: false
      },

      # Pivot table configuration (Selecto 0.3.0+)
      pivot: %{},

      # Join configurations
      joins: %{
        :category => %{
          name: "Category",
          type: :inner
        },
        :supplier => %{
          name: "Supplier",
          type: :inner
        },
        :order_details => %{
          name: "Order Details",
          type: :left
        }
      }
    }
  end

  @doc "Create a new Selecto instance configured with this domain."
  def new(repo, opts \\ []) do
    # Enable validation by default in development and test environments
    validate = Keyword.get(opts, :validate, Mix.env() in [:dev, :test])
    opts = Keyword.put(opts, :validate, validate)

    Selecto.configure(domain(), repo, opts)
  end

  @doc "Create a Selecto instance using Ecto integration."
  def from_ecto(repo, opts \\ []) do
    Selecto.from_ecto(repo, SelectoNorthwind.Catalog.Product, opts)
  end

  @doc "Validate the domain configuration (Selecto 0.3.0+)."
  def validate_domain! do
    case Selecto.DomainValidator.validate_domain(domain()) do
      :ok ->
        :ok

      {:error, errors} ->
        raise Selecto.DomainValidator.ValidationError, errors: errors
    end
  end

  @doc "Check if the domain configuration is valid."
  def valid_domain? do
    case Selecto.DomainValidator.validate_domain(domain()) do
      :ok -> true
      {:error, _} -> false
    end
  end

  @doc "Get the schema module this domain represents."
  def schema_module, do: SelectoNorthwind.Catalog.Product

  @doc "Get available fields (derived from columns to avoid duplication)."
  def available_fields do
    domain().source.columns |> Map.keys()
  end

  @doc "Common query: get all records with default selection."
  def all(repo, opts \\ []) do
    new(repo, opts)
    |> Selecto.select(domain().default_selected)
    |> Selecto.execute()
  end

  @doc "Common query: find by primary key."
  def find(repo, id, opts \\ []) do
    primary_key = domain().source.primary_key

    new(repo, opts)
    |> Selecto.select(domain().default_selected)
    |> Selecto.filter({to_string(primary_key), id})
    |> Selecto.execute_one()
  end

  @doc "Common query: filter by category_id."
  def by_category_id(repo, value, opts \\ []) do
    new(repo, opts)
    |> Selecto.select(domain().default_selected)
    |> Selecto.filter({"category_id", value})
    |> Selecto.execute()
  end

  @doc "Common query: filter by discontinued."
  def by_discontinued(repo, value, opts \\ []) do
    new(repo, opts)
    |> Selecto.select(domain().default_selected)
    |> Selecto.filter({"discontinued", value})
    |> Selecto.execute()
  end
end
