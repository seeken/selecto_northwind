defmodule SelectoNorthwind.SelectoDomains.Overlays.ProductDomainOverlay do
  @moduledoc """
  Overlay configuration for SelectoNorthwind.SelectoDomains.ProductDomain.

  This file contains user-defined customizations for the domain configuration.
  It will NOT be overwritten when you regenerate the domain file.

  ## Purpose

   Use this overlay file to:
   - Customize column display properties (labels, formats, aggregations)
   - Add redaction to sensitive fields
   - Define custom filters
   - Register named UDFs with `deffunction`
   - Define JSONB schemas for structured data columns
   - Define named query members (CTE/VALUES/subquery/LATERAL/UNNEST presets)
   - Bind fields to choice sources with resolver constraint policies
   - Define write contracts, actions, and capabilities for Updato/tooling
   - Add domain-specific validations (future)
  - Configure custom transformations (future)

  ## DSL Usage

  This overlay uses a clean DSL (Domain-Specific Language) syntax:

      # Module attributes for redactions
      @redactions [:field1, :field2]

      # Column customizations with defcolumn
      defcolumn :price do
        label "Product Price"
        format :currency
        aggregate_functions [:sum, :avg]
      end

       # Custom filters with deffilter
       deffilter "price_range" do
         name "Price Range"
         type :string
         description "Filter by price range"
       end

       # UDF registrations with deffunction
       deffunction "similarity" do
         kind :scalar
         sql_name "public.similarity"
         args [
           %{name: :left, type: :string, source: :selector},
           %{name: :right, type: :string, source: :value}
         ]
         returns :float
         allowed_in [:select, :order_by]
       end

      # JSONB schema definitions with defjsonb_schema
      defjsonb_schema :attributes do
        %{
          "color" => %{type: :string, required: true},
          "size" => %{type: :string, enum: ["small", "medium", "large"]}
        }
      end

      # Named CTE/VALUES/subquery/LATERAL/UNNEST presets
      defcte :active_rows do
        query &__MODULE__.active_rows_cte/1
        columns ["id"]
        join [owner_key: :id, related_key: :id]
      end

      defvalues :status_lookup do
        rows [["active", "Active"], ["inactive", "Inactive"]]
        columns ["status", "label"]
        as "status_lookup"
        join [owner_key: :status, related_key: :status]
      end

      defsubquery :high_value_rows do
        query &__MODULE__.high_value_rows_subquery/1
        on [%{left: "id", right: "entity_id"}]
      end

      deflateral :recent_series do
        source {:function, :generate_series, [1, 3]}
        as "recent_series"
        join_type :inner
      end

      defunnest :tag_values do
        array_field "tags"
        as "tag_value"
        ordinality "tag_position"
      end

      # Choice-source metadata for async pickers and membership validation
      defsource_relationship(:customer, %{
        target_domain: :customers,
        source_field: :customer_id,
        target_field: :id,
        source_path: "customer"
      })

      defchoice_source(:customer_choices, %{
        domain: :customers,
        value_field: :id,
        label_field: :name,
        source_relationship: :customer,
        constraint_policy: %{domain_of_interest: :fail_closed},
        presentation: %{control: :autocomplete, mode: :async, cardinality: :one}
      })

      # Write contract metadata
      defwrite_operation :update do
        enabled true
        require_filter true
        returning :record
      end

      defwrite_field :name do
        insertable true
        updatable true
        required_on [:insert]
      end

      defcapability "entity.write" do
        operations [:insert, :update]
      end

  ## How It Works

  The DSL compiles into an overlay configuration map that is merged with the
  base domain configuration at runtime. Column configurations are deep-merged,
  allowing you to override or extend specific properties without replacing
  the entire column configuration.

  ## Examples

  See the commented examples below for common customization patterns based on
  your schema.
  """

  use Selecto.Config.OverlayDSL

  # Uncomment to redact sensitive fields from query results
  # @redactions [:sensitive_field1, :sensitive_field2]

  # Uncomment and customize column configurations as needed
  # defcolumn :attributes do
  #   label "Attributes"
  #   max_length 100
  # end

  # defcolumn :id do
  #   label "Id"
  #   aggregate_functions [:sum, :avg, :count, :min, :max]
  # end

  # defcolumn :inserted_at do
  #   label "Inserted At"
  #   max_length 100
  # end

  # Uncomment and add custom filters
  # deffilter "id_range" do
  #   name "Id Range"
  #   type :string
  #   description "Filter by id range (e.g., '100-500')"
  # end

  # Uncomment and register domain UDFs
  # deffunction "similarity" do
  #   kind :scalar
  #   sql_name "public.similarity"
  #   args [
  #     %{name: :left, type: :string, source: :selector},
  #     %{name: :right, type: :string, source: :value}
  #   ]
  #   returns :float
  #   allowed_in [:select, :order_by]
  # end

  # deffunction "nearby_points" do
  #   kind :table
  #   sql_name "gis.nearby_points"
  #   args [
  #     %{name: :origin, type: :geometry, source: :selector},
  #     %{name: :radius_m, type: :integer, source: :value}
  #   ]
  #   returns %{columns: %{id: %{type: :integer}, distance_m: %{type: :float}}}
  #   allowed_in [:lateral, :query_member]
  # end

  # Optional named query members (used by Selecto.with_cte/2, with_values/2,
  # with_subquery/2, with_lateral/2, and with_unnest/2)
  # defcte :active_rows do
  #   query &__MODULE__.active_rows_cte/1
  #   columns ["id"]
  #   join [owner_key: :id, related_key: :id, fields: :infer]
  # end

  # defvalues :status_lookup do
  #   rows [["active", "Active"], ["inactive", "Inactive"]]
  #   columns ["status", "label"]
  #   as "status_lookup"
  #   join [owner_key: :status, related_key: :status]
  # end

  # defsubquery :high_value_rows do
  #   query &__MODULE__.high_value_rows_subquery/1
  #   type :inner
  #   on [%{left: "id", right: "entity_id"}]
  # end

  # deflateral :recent_series do
  #   source {:function, :generate_series, [1, 3]}
  #   as "recent_series"
  #   join_type :inner
  # end

  # defunnest :tag_values do
  #   array_field "tags"
  #   as "tag_value"
  #   ordinality "tag_position"
  # end

  # Optional choice-source metadata for async pickers and membership validation
  # Keep tenant/actor/filter scope server-owned in your resolver. If a trusted
  # Domain-of-Interest filter cannot be enforced, `:fail_closed` lets the
  # resolver return a closed result instead of a partial option set.
  # defcolumn :supplier_id do
  #   choice_source :supplier_choices
  #   reference %{
  #     choice_source: :supplier_choices,
  #     value_source: "supplier.id",
  #     caption_source: "supplier.name"
  #   }
  # end

  # defsource_relationship(:supplier, %{
  #   target_domain: :suppliers,
  #   source_field: :supplier_id,
  #   target_field: :id,
  #   source_path: "supplier"
  # })

  # defchoice_source(:supplier_choices, %{
  #   domain: :suppliers,
  #   value_field: :id,
  #   label_field: :name,
  #   source_relationship: :supplier,
  #   constraint_policy: %{domain_of_interest: :fail_closed},
  #   presentation: %{control: :autocomplete, mode: :async, cardinality: :one}
  # })

  # Optional write contract metadata (projected by SelectoUpdato.DomainContract)
  # defwrite_operation :insert do
  #   enabled true
  #   returning :record
  # end

  # defwrite_operation :update do
  #   enabled true
  #   require_filter true
  #   returning :record
  # end

  # defwrite_field :product_name do
  #   insertable true
  #   updatable true
  #   required_on [:insert]
  # end

  # defcapability "entity.write" do
  #   operations [:insert, :update]
  # end

  # ============================================================================
  # JSONB Schema Definitions
  # ============================================================================
  #
  # Define the structure of your JSONB columns to enable:
  # - Type-safe filtering with dot notation (e.g., attributes.color = "red")
  # - Validation on inserts/updates
  # - GraphQL type generation
  #
  # Uncomment and customize the schema definitions below:

  # defjsonb_schema :attributes do
  #   %{
  #     # String field with validation
  #     "color" => %{type: :string, required: true},
  #
  #     # Enum field with allowed values
  #     "size" => %{type: :string, enum: ["small", "medium", "large", "xl"]},
  #
  #     # Numeric field with bounds
  #     "weight" => %{type: :decimal, min: 0},
  #
  #     # Boolean field with default
  #     "in_stock" => %{type: :boolean, default: true},
  #
  #     # Nested object
  #     "dimensions" => %{
  #       type: :object,
  #       schema: %{
  #         "length" => %{type: :decimal, required: true},
  #         "width" => %{type: :decimal},
  #         "height" => %{type: :decimal}
  #       }
  #     },
  #
  #     # Array of strings
  #     "tags" => %{
  #       type: :array,
  #       items: %{type: :string}
  #     }
  #   }
  # end
end
