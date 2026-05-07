defmodule SelectoNorthwind.SelectoDomains.ProductDomain do
  @moduledoc """
  Selecto domain configuration for SelectoNorthwind.Catalog.Product.

  This file was automatically generated from the Ecto schema.

  ## Customization with Overlay Files

  This domain uses an overlay configuration system for customization.
  Instead of editing this file directly, customize the domain by editing:

      lib/*/selecto_domains/overlays/*_overlay.ex

  The overlay file allows you to:
  - Customize column display properties (labels, formats, aggregations)
  - Add redaction to sensitive fields
  - Define custom filters
  - Define write contracts, actions, and capabilities
  - Add domain-specific validations (future)

  Your overlay customizations are preserved when you regenerate this file.

  ## Usage

        # Basic usage
      selecto = Selecto.configure(SelectoNorthwind.SelectoDomains.ProductDomain.domain(), MyApp.Repo)

      # With Ecto integration
      selecto = Selecto.from_ecto(MyApp.Repo, SelectoNorthwind.Catalog.Product)

      # Execute queries
      {:ok, {rows, columns, aliases}} = Selecto.execute(selecto)


  ## Legacy Customization (Deprecated)

  Fields, filters, and joins marked with "# CUSTOM" comments will still be
  preserved when this file is regenerated, but we recommend using the
  overlay file instead for a cleaner separation of generated vs. custom code.

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

  This merges the base domain configuration with any overlay customizations.
  """
  def domain do
    base_domain()
    |> Selecto.Config.Overlay.merge(overlay())
  end

  @doc """
  Returns the base domain configuration (without overlay customizations).
  """
  def base_domain do
    %{
      # Generated from: SelectoNorthwind.Catalog.Product
      # Last updated: 2026-05-07T04:39:05.879909Z

      # Canonical Selecto domain schema version
      schema_version: 1,
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
          :attributes,
          :supplier_id,
          :category_id,
          :inserted_at,
          :updated_at
        ],

        # Fields to exclude from queries
        redact_fields: [],

        # Field type definitions (contains the same info as fields above)
        columns: %{
          :attributes => %{type: :jsonb, schema: :stub},
          :id => %{type: :integer},
          :inserted_at => %{type: :naive_datetime},
          :product_name => %{type: :string},
          :quantity_per_unit => %{type: :string},
          :unit_price => %{type: :decimal},
          :units_in_stock => %{type: :integer},
          :units_on_order => %{type: :integer},
          :reorder_level => %{type: :integer},
          :discontinued => %{type: :boolean},
          :supplier_id => %{type: :integer},
          :category_id => %{type: :integer},
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
          :tags => %{
            queryable: :tag,
            field: :tags,
            owner_key: :id,
            related_key: :id,
            join_through: "product_tags",
            join_keys: [product_id: :id, tag_id: :id]
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
          },
          :product_flags => %{
            queryable: :product_flag,
            field: :product_flags,
            owner_key: :id,
            related_key: :product_id
          },
          :flag_types => %{
            queryable: :flag_type,
            field: :flag_types,
            owner_key: :id,
            related_key: :id,
            join_through: "product_flags",
            join_keys: [product_id: :id, flag_type_id: :id]
          }
        }
      },
      schemas: %{
        :category => %{
          # TODO: Add proper schema configuration for SelectoNorthwind.Catalog.Category
          # This will be auto-generated when you run:
          # mix selecto.gen.domain SelectoNorthwind.Catalog.Category
          # Or use --expand-schemas category to expand automatically
          source_table: "categorys",
          primary_key: :id,
          # Add fields for SelectoNorthwind.Catalog.Category
          fields: [],
          redact_fields: [],
          columns: %{},
          associations: %{}
        },
        :tag => %{
          # TODO: Add proper schema configuration for SelectoNorthwind.Catalog.Tag
          # This will be auto-generated when you run:
          # mix selecto.gen.domain SelectoNorthwind.Catalog.Tag
          # Or use --expand-schemas tag to expand automatically
          source_table: "tags",
          primary_key: :id,
          # Add fields for SelectoNorthwind.Catalog.Tag
          fields: [],
          redact_fields: [],
          columns: %{},
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
        },
        :product_flag => %{
          # TODO: Add proper schema configuration for SelectoNorthwind.Support.ProductFlag
          # This will be auto-generated when you run:
          # mix selecto.gen.domain SelectoNorthwind.Support.ProductFlag
          # Or use --expand-schemas product_flag to expand automatically
          source_table: "product_flags",
          primary_key: :id,
          # Add fields for SelectoNorthwind.Support.ProductFlag
          fields: [],
          redact_fields: [],
          columns: %{},
          associations: %{}
        },
        :flag_type => %{
          # TODO: Add proper schema configuration for SelectoNorthwind.Support.FlagType
          # This will be auto-generated when you run:
          # mix selecto.gen.domain SelectoNorthwind.Support.FlagType
          # Or use --expand-schemas flag_type to expand automatically
          source_table: "flag_types",
          primary_key: :id,
          # Add fields for SelectoNorthwind.Support.FlagType
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

      # Named UDF registry (prefer overlay deffunction for custom additions)
      functions: %{},

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

      # Retarget table configuration (Selecto 0.3.0+)
      retarget: %{},

      # Join configurations
      joins: %{
        :category => %{
          name: "Category",
          type: :inner,
          source: :categorys,
          on: [%{left: "category_id", right: "id"}]
        },
        :tags => %{
          name: "Tags",
          type: :left,
          source: :tags,
          on: [%{left: "id", right: "id"}],
          join_table: "product_tags",
          join_through: "product_tags",
          join_keys: [product_id: :id, tag_id: :id],
          main_foreign_key: "product_id",
          tag_foreign_key: "tag_id",
          owner_key: :id,
          assoc_key: :id
        },
        :supplier => %{
          name: "Supplier",
          type: :inner,
          source: :suppliers,
          on: [%{left: "supplier_id", right: "id"}]
        },
        :order_details => %{
          name: "Order Details",
          type: :left,
          source: :order_details,
          on: [%{left: "id", right: "product_id"}]
        },
        :product_flags => %{
          name: "Product Flags",
          type: :left,
          source: :product_flags,
          on: [%{left: "id", right: "product_id"}]
        },
        :flag_types => %{
          name: "Flag Types",
          type: :left,
          source: :flag_types,
          on: [%{left: "id", right: "id"}],
          join_table: "product_flags",
          join_through: "product_flags",
          join_keys: [product_id: :id, flag_type_id: :id],
          main_foreign_key: "product_id",
          tag_foreign_key: "flag_type_id",
          owner_key: :id,
          assoc_key: :id
        }
      }
    }
  end

  @doc """
  Returns the overlay configuration if available.

  The overlay file is located at:
  lib/*/selecto_domains/overlays/*_overlay.ex
  """
  def overlay do
    if Code.ensure_loaded?(SelectoNorthwind.SelectoDomains.Overlays.ProductDomainOverlay) do
      SelectoNorthwind.SelectoDomains.Overlays.ProductDomainOverlay.overlay()
    else
      %{}
    end
  end

  @doc "Create a new Selecto instance configured with this domain."
  def new(connection, opts \\ []) do
    # Enable validation by default in development and test environments
    validate = Keyword.get(opts, :validate, Mix.env() in [:dev, :test])
    opts = Keyword.put(opts, :validate, validate)

    Selecto.configure(domain(), connection, opts)
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

  @doc "Create a Selecto instance using Ecto integration."
  def from_ecto(repo, opts \\ []) do
    Selecto.from_ecto(repo, SelectoNorthwind.Catalog.Product, opts)
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
