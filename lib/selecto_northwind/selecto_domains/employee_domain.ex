defmodule SelectoNorthwind.SelectoDomains.EmployeeDomain do
  @moduledoc """
  Selecto domain configuration for SelectoNorthwind.Hr.Employee.

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

  Overlay customizations are preserved when you regenerate this file.

  ## Usage

        # Basic usage
      selecto = Selecto.configure(SelectoNorthwind.SelectoDomains.EmployeeDomain.domain(), MyApp.Repo)

      # With Ecto integration
      selecto = Selecto.from_ecto(MyApp.Repo, SelectoNorthwind.Hr.Employee)

      # Execute queries
      {:ok, {rows, columns, aliases}} = Selecto.execute(selecto)


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

      mix selecto.gen.domain SelectoNorthwind.Hr.Employee

  Additional options:

      # Force regenerate the generated base file
      mix selecto.gen.domain SelectoNorthwind.Hr.Employee --force

      # Preview changes without writing files
      mix selecto.gen.domain SelectoNorthwind.Hr.Employee --dry-run

      # Include associations as joins
      mix selecto.gen.domain SelectoNorthwind.Hr.Employee --include-associations

      # Generate with LiveView files
      mix selecto.gen.domain SelectoNorthwind.Hr.Employee --live

      # Generate with saved views support
      mix selecto.gen.domain SelectoNorthwind.Hr.Employee --live --saved-views

      # Expand specific associated schemas with full columns/associations
      mix selecto.gen.domain SelectoNorthwind.Hr.Employee --expand-schemas categories,tags

  Keep app-specific customizations in the overlay module so regeneration can
  replace this generated base file intentionally.
  """

  use SelectoNorthwind.SavedViewContext

  @doc """
  Returns the Selecto domain configuration for SelectoNorthwind.Hr.Employee.

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
      # Generated from: SelectoNorthwind.Hr.Employee
      # Canonical Selecto domain schema version
      schema_version: 1,

      # Authored domain version; update when this domain contract changes meaning
      domain_version: "0.1.0",

      # Optional content fingerprint; populate from a stable artifact hash when available
      # domain_fingerprint: "sha256:...",

      source: %{
        source_table: "employees",
        primary_key: :id,

        # Available fields from schema
        # NOTE: This is redundant with columns - consider using Map.keys(columns) instead
        fields: [
          :id,
          :last_name,
          :first_name,
          :title,
          :title_of_courtesy,
          :birth_date,
          :hire_date,
          :address,
          :city,
          :region,
          :postal_code,
          :country,
          :home_phone,
          :extension,
          :photo,
          :notes,
          :photo_path,
          :reports_to,
          :inserted_at,
          :updated_at
        ],

        # Fields to exclude from queries
        redact_fields: [],

        # Field type definitions (contains the same info as fields above)
        columns: %{
          :address => %{type: :string},
          :birth_date => %{type: :date},
          :city => %{type: :string},
          :country => %{type: :string},
          :extension => %{type: :string},
          :first_name => %{type: :string},
          :hire_date => %{type: :date},
          :home_phone => %{type: :string},
          :id => %{type: :integer},
          :inserted_at => %{type: :naive_datetime},
          :last_name => %{type: :string},
          :notes => %{type: :string},
          :photo => %{type: :string},
          :photo_path => %{type: :string},
          :postal_code => %{type: :string},
          :region => %{type: :string},
          :reports_to => %{type: :integer},
          :title => %{type: :string},
          :title_of_courtesy => %{type: :string},
          :updated_at => %{type: :naive_datetime}
        },

        # Schema associations
        associations: %{
          :manager => %{
            queryable: :employee,
            field: :manager,
            owner_key: :reports_to,
            related_key: :id
          },
          :orders => %{
            queryable: :order,
            field: :orders,
            owner_key: :id,
            related_key: :employee_id
          },
          :subordinates => %{
            queryable: :employee,
            field: :subordinates,
            owner_key: :id,
            related_key: :reports_to
          },
          :territories => %{
            queryable: :territory,
            field: :territories,
            owner_key: :id,
            related_key: :id,
            join_through: "employee_territories",
            join_keys: [employee_id: :id, territory_id: :territory_id]
          }
        }
      },
      schemas: %{
        :employee => %{
          # Placeholder for SelectoNorthwind.Hr.Employee; run
          # mix selecto.gen.domain SelectoNorthwind.Hr.Employee
          # or add --expand-schemas employee to expand this schema automatically
          source_table: "employees",
          primary_key: :id,
          fields: [],
          redact_fields: [],
          columns: %{},
          associations: %{}
        },
        :order => %{
          # Expanded schema configuration for orders
          source_table: "orders",
          primary_key: :id,
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
          redact_fields: [],
          columns: %{
            :customer_id => %{type: :string},
            :employee_id => %{type: :integer},
            :freight => %{type: :decimal},
            :id => %{type: :integer},
            :inserted_at => %{type: :naive_datetime},
            :order_date => %{type: :date},
            :required_date => %{type: :date},
            :ship_address => %{type: :string},
            :ship_city => %{type: :string},
            :ship_country => %{type: :string},
            :ship_name => %{type: :string},
            :ship_postal_code => %{type: :string},
            :ship_region => %{type: :string},
            :ship_via => %{type: :integer},
            :shipped_date => %{type: :date},
            :updated_at => %{type: :naive_datetime}
          },
          associations: %{}
        },
        :territory => %{
          # Expanded schema configuration for territories
          source_table: "territories",
          primary_key: :territory_id,
          fields: [:territory_id, :territory_description, :region_id, :inserted_at, :updated_at],
          redact_fields: [],
          columns: %{
            :inserted_at => %{type: :naive_datetime},
            :region_id => %{type: :integer},
            :territory_description => %{type: :string},
            :territory_id => %{type: :string},
            :updated_at => %{type: :naive_datetime}
          },
          associations: %{}
        }
      },
      name: "Employee Domain",

      # Default selections (customize as needed)
      default_selected: ["id", "last_name", "first_name", "title", "title_of_courtesy"],

      # Suggested filters (add/remove as needed)
      filters: %{},

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
        :manager => %{
          name: "Manager",
          type: :inner,
          source: :employees,
          on: [%{left: "reports_to", right: "id"}]
        },
        :orders => %{
          name: "Orders",
          type: :left,
          source: :orders,
          on: [%{left: "id", right: "employee_id"}]
        },
        :subordinates => %{
          name: "Subordinates",
          type: :left,
          source: :employees,
          on: [%{left: "id", right: "reports_to"}]
        },
        :territories => %{
          name: "Territories",
          type: :left,
          source: :territorys,
          on: [%{left: "id", right: "id"}],
          join_table: "employee_territories",
          join_through: "employee_territories",
          join_keys: [employee_id: :id, territory_id: :territory_id],
          main_foreign_key: "employee_id",
          tag_foreign_key: "territory_id",
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
    if Code.ensure_loaded?(SelectoNorthwind.SelectoDomains.Overlays.EmployeeDomainOverlay) do
      SelectoNorthwind.SelectoDomains.Overlays.EmployeeDomainOverlay.overlay()
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
    Selecto.from_ecto(repo, SelectoNorthwind.Hr.Employee, opts)
  end

  @doc "Get the schema module this domain represents."
  def schema_module, do: SelectoNorthwind.Hr.Employee

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
