defmodule SelectoNorthwind.SelectoDomains.OrderDomain do
  @moduledoc """
  Selecto domain configuration for SelectoNorthwind.Sales.Order.

  This file was automatically generated from the Ecto schema.

  ## Customization with Overlay Files

  This domain uses an overlay configuration system for customization.
  Instead of editing this file directly, customize the domain by editing:

      lib/*/selecto_domains/overlays/*_overlay.ex

  The overlay file allows you to:
  - Customize column display properties (labels, formats, aggregations)
  - Add redaction to sensitive fields
  - Define custom filters
  - Add domain-specific validations (future)

  Your overlay customizations are preserved when you regenerate this file.

  ## Usage

      # Basic usage
      selecto = Selecto.configure(SelectoNorthwind.SelectoDomains.OrderDomain.domain(), MyApp.Repo)

      # With Ecto integration
      selecto = Selecto.from_ecto(MyApp.Repo, SelectoNorthwind.Sales.Order)

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

      mix selecto.gen.domain SelectoNorthwind.Sales.Order
      
  Additional options:

      # Force regenerate (overwrites customizations)
      mix selecto.gen.domain SelectoNorthwind.Sales.Order --force
      
      # Preview changes without writing files
      mix selecto.gen.domain SelectoNorthwind.Sales.Order --dry-run
      
      # Include associations as joins
      mix selecto.gen.domain SelectoNorthwind.Sales.Order --include-associations
      
      # Generate with LiveView files
      mix selecto.gen.domain SelectoNorthwind.Sales.Order --live
      
      # Generate with saved views support
      mix selecto.gen.domain SelectoNorthwind.Sales.Order --live --saved-views
      
      # Expand specific associated schemas with full columns/associations
      mix selecto.gen.domain SelectoNorthwind.Sales.Order --expand-schemas categories,tags
      
  Your customizations will be preserved during regeneration (unless --force is used).
  """

  use SelectoNorthwind.SavedViewContext

  @doc """
  Returns the Selecto domain configuration for SelectoNorthwind.Sales.Order.

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
      # Generated from schema: Elixir.SelectoNorthwind.Sales.Order
      # Last updated: 2026-01-26T04:54:35.730141Z

      source: %{
        source_table: "orders",
        primary_key: :id,

        # Available fields from schema
        # NOTE: This is redundant with columns - consider using Map.keys(columns) instead
        fields: [
          :id,
          :order_date,
          :required_date,
          :shipped_date,
          :freight,
          :ship_name,
          :ship_address,
          :ship_city,
          :ship_region,
          :ship_postal_code,
          :ship_country,
          :customer_id,
          :employee_id,
          :ship_via,
          :inserted_at,
          :updated_at
        ],

        # Fields to exclude from queries
        redact_fields: [],

        # Field type definitions (contains the same info as fields above)
        columns: %{
          :id => %{type: :integer},
          :customer_id => %{type: :string},
          :inserted_at => %{type: :naive_datetime},
          :updated_at => %{type: :naive_datetime},
          :order_date => %{type: :date},
          :required_date => %{type: :date},
          :shipped_date => %{type: :date},
          :freight => %{type: :decimal},
          :ship_name => %{type: :string},
          :ship_address => %{type: :string},
          :ship_city => %{type: :string},
          :ship_region => %{type: :string},
          :ship_postal_code => %{type: :string},
          :ship_country => %{type: :string},
          :employee_id => %{type: :integer},
          :ship_via => %{type: :integer}
        },

        # Schema associations
        associations: %{
          :order_details => %{
            queryable: :order_detail,
            field: :order_details,
            owner_key: :id,
            related_key: :order_id
          },
          :customer => %{
            queryable: :customer,
            field: :customer,
            owner_key: :customer_id,
            related_key: :customer_id
          },
          :employee => %{
            queryable: :employee,
            field: :employee,
            owner_key: :employee_id,
            related_key: :id
          },
          :shipper => %{
            queryable: :shipper,
            field: :shipper,
            owner_key: :ship_via,
            related_key: :id
          }
        }
      },
      schemas: %{
        :order_detail => %{
          # Expanded schema configuration for SelectoNorthwind.Sales.OrderDetail
          source_table: "order_details",
          primary_key: :order_id,
          fields: [
            :unit_price,
            :quantity,
            :discount,
            :order_id,
            :product_id,
            :inserted_at,
            :updated_at
          ],
          redact_fields: [],
          columns: %{
            :inserted_at => %{type: :naive_datetime},
            :updated_at => %{type: :naive_datetime},
            :unit_price => %{type: :decimal},
            :product_id => %{type: :integer},
            :order_id => %{type: :integer},
            :quantity => %{type: :integer},
            :discount => %{type: :decimal}
          },
          associations: %{}
        },
        :customer => %{
          # TODO: Add proper schema configuration for SelectoNorthwind.Sales.Customer
          # This will be auto-generated when you run:
          # mix selecto.gen.domain SelectoNorthwind.Sales.Customer
          # Or use --expand-schemas customer to expand automatically
          source_table: "customers",
          primary_key: :id,
          # Add fields for SelectoNorthwind.Sales.Customer
          fields: [],
          redact_fields: [],
          columns: %{},
          associations: %{}
        },
        :employee => %{
          # TODO: Add proper schema configuration for SelectoNorthwind.Hr.Employee
          # This will be auto-generated when you run:
          # mix selecto.gen.domain SelectoNorthwind.Hr.Employee
          # Or use --expand-schemas employee to expand automatically
          source_table: "employees",
          primary_key: :id,
          # Add fields for SelectoNorthwind.Hr.Employee
          fields: [],
          redact_fields: [],
          columns: %{},
          associations: %{}
        },
        :shipper => %{
          # TODO: Add proper schema configuration for SelectoNorthwind.Sales.Shipper
          # This will be auto-generated when you run:
          # mix selecto.gen.domain SelectoNorthwind.Sales.Shipper
          # Or use --expand-schemas shipper to expand automatically
          source_table: "shippers",
          primary_key: :id,
          # Add fields for SelectoNorthwind.Sales.Shipper
          fields: [],
          redact_fields: [],
          columns: %{},
          associations: %{}
        }
      },
      name: "Order Domain",

      # Default selections (customize as needed)
      default_selected: ["id", "ship_name", "customer_id", "employee_id"],

      # Suggested filters (add/remove as needed)
      filters: %{},

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
        :order_details => %{
          name: "Order Details",
          type: :left,
          source: :order_details,
          on: [%{left: "id", right: "order_id"}]
        },
        :customer => %{
          name: "Customer",
          type: :inner,
          source: :customers,
          on: [%{left: "customer_id", right: "customer_id"}]
        },
        :employee => %{
          name: "Employee",
          type: :inner,
          source: :employees,
          on: [%{left: "employee_id", right: "id"}]
        },
        :shipper => %{
          name: "Shipper",
          type: :inner,
          source: :shippers,
          on: [%{left: "ship_via", right: "id"}]
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
    if Code.ensure_loaded?(SelectoNorthwind.SelectoDomains.Overlays.OrderDomainOverlay) do
      SelectoNorthwind.SelectoDomains.Overlays.OrderDomainOverlay.overlay()
    else
      %{}
    end
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
    Selecto.from_ecto(repo, SelectoNorthwind.Sales.Order, opts)
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
  def schema_module, do: SelectoNorthwind.Sales.Order

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
end
