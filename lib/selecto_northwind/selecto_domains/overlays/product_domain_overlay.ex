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

  # ============================================================================
  # JSONB Schema Definitions
  # ============================================================================
  #
  # Define the structure of your JSONB columns to enable:
  # - Type-safe filtering with dot notation (e.g., attributes.color = "red")
  # - Validation on inserts/updates
  # - GraphQL type generation
  defjsonb_schema :attributes do
    %{
      "color" => %{type: :string},
      "size" => %{type: :string, enum: ["small", "medium", "large", "xl"]},
      "weight" => %{type: :decimal, min: 0},
      "material" => %{type: :string},
      "organic" => %{type: :boolean, default: false},
      "dimensions" => %{
        type: :object,
        schema: %{
          "length" => %{type: :decimal},
          "width" => %{type: :decimal},
          "height" => %{type: :decimal},
          "unit" => %{type: :string, enum: ["cm", "in", "mm"], default: "cm"}
        }
      },
      "tags" => %{
        type: :array,
        items: %{type: :string}
      }
    }
  end
end
