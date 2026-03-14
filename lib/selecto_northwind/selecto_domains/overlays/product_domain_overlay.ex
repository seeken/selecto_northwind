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
  - Define JSONB schemas for structured data columns
  - Define named query members (CTE/VALUES/subquery/LATERAL/UNNEST presets)
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
  # defcolumn :field_name do
  #   label "Custom Label"
  #   format :currency  # or :percentage, :number, :date, etc.
  #   aggregate_functions [:sum, :avg, :min, :max]
  # end

  # Uncomment and add custom filters
  # deffilter "custom_filter" do
  #   name "Custom Filter"
  #   type :string
  #   description "Your custom filter description"
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
