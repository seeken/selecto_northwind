# Structured JSONB Support for Selecto Ecosystem

## Overview

Add the ability to define structured JSONB columns in Selecto domains with full schema descriptions. This enables:
- **Selecto**: Filter and select within JSONB structures using `->>` and `->` operators
- **SelectoUpdato**: Validate and insert/update JSONB data against the schema
- **SelectoAbsinthe**: Generate GraphQL input types and query filters for JSONB fields

## Use Cases

1. **Product attributes**: `%{color: "red", size: "large", weight: 2.5}`
2. **User preferences**: `%{theme: "dark", notifications: %{email: true, sms: false}}`
3. **Order metadata**: `%{gift_message: "Happy Birthday", priority: "express"}`
4. **Audit logs**: `%{changes: [...], user_agent: "...", ip: "..."}`

## Proposed Domain Configuration

```elixir
def domain do
  %{
    name: "products",
    source: Product,

    columns: %{
      "id" => %{type: :integer},
      "name" => %{type: :string},
      "price" => %{type: :decimal},

      # Structured JSONB column
      "attributes" => %{
        type: :jsonb,
        schema: %{
          "color" => %{type: :string, required: true},
          "size" => %{type: :string, enum: ["small", "medium", "large"]},
          "weight" => %{type: :decimal},
          "dimensions" => %{
            type: :object,
            schema: %{
              "length" => %{type: :decimal},
              "width" => %{type: :decimal},
              "height" => %{type: :decimal}
            }
          },
          "tags" => %{type: :array, items: %{type: :string}},
          "features" => %{
            type: :array,
            items: %{
              type: :object,
              schema: %{
                "name" => %{type: :string, required: true},
                "value" => %{type: :string}
              }
            }
          }
        }
      }
    }
  }
end
```

## Implementation Plan

### Phase 1: Selecto Core - JSONB Filtering & Selection

**Files to modify:**
- `vendor/selecto/lib/selecto/builder/select.ex`
- `vendor/selecto/lib/selecto/builder/sql/where.ex`
- `vendor/selecto/lib/selecto/schema.ex` (or new `jsonb_schema.ex`)

**Changes:**

1. **Column path syntax**: Support dot notation for JSONB paths
   ```elixir
   # Filter by nested JSONB field
   Selecto.configure(domain)
   |> Selecto.filter({"attributes.color", "red"})
   |> Selecto.filter({"attributes.dimensions.length", %{gt: 10}})
   ```

2. **SQL generation**: Generate proper PostgreSQL JSONB operators
   ```sql
   -- Text extraction (->>)
   WHERE attributes->>'color' = 'red'

   -- Nested path (#>>)
   WHERE attributes#>>'{dimensions,length}' > '10'

   -- Contains (@>)
   WHERE attributes @> '{"color": "red"}'

   -- Array contains
   WHERE attributes->'tags' ? 'featured'
   ```

3. **Select JSONB fields**:
   ```elixir
   Selecto.select(["id", "name", "attributes.color", "attributes.size"])
   ```

4. **Type casting in queries**: Cast JSONB values for comparisons
   ```sql
   WHERE (attributes->>'weight')::decimal > 2.5
   ```

### Phase 2: SelectoUpdato - JSONB Validation & Mutation

**Files to modify:**
- `vendor/selecto_updato/lib/selecto_updato/validation.ex`
- `vendor/selecto_updato/lib/selecto_updato/changeset.ex`
- New: `vendor/selecto_updato/lib/selecto_updato/jsonb_validator.ex`

**Changes:**

1. **JSONB Schema Validator**:
   ```elixir
   defmodule SelectoUpdato.JsonbValidator do
     def validate(data, schema) do
       # Recursively validate:
       # - Required fields
       # - Type checking
       # - Enum values
       # - Nested objects
       # - Arrays with item schemas
     end
   end
   ```

2. **Integration with changeset building**:
   ```elixir
   # When building changeset, validate JSONB columns
   def build(op, attrs, :insert) do
     # ... existing logic ...
     |> validate_jsonb_columns(domain)
   end
   ```

3. **Partial JSONB updates**: Support updating specific paths
   ```elixir
   SelectoUpdato.new(domain)
   |> SelectoUpdato.filter({"id", 123})
   |> SelectoUpdato.update(%{
     "attributes.color" => "blue",           # Update single field
     "attributes.dimensions" => %{...}       # Replace nested object
   })
   ```

4. **JSONB merge strategies**:
   - `:replace` - Replace entire JSONB column (default)
   - `:merge_shallow` - Shallow merge with existing
   - `:merge_deep` - Deep merge with existing
   - `:patch` - JSON Patch (RFC 6902) operations

### Phase 3: SelectoAbsinthe - GraphQL Types for JSONB

**Files to modify:**
- `vendor/selecto_absinthe/lib/selecto_absinthe/type_builder.ex`
- `vendor/selecto_absinthe/lib/selecto_absinthe/input_builder.ex`
- `vendor/selecto_absinthe/lib/selecto_absinthe/filter_builder.ex`

**Changes:**

1. **Generate GraphQL types from JSONB schema**:
   ```graphql
   type ProductAttributes {
     color: String!
     size: ProductSize
     weight: Float
     dimensions: ProductDimensions
     tags: [String!]
     features: [ProductFeature!]
   }

   enum ProductSize {
     SMALL
     MEDIUM
     LARGE
   }

   type ProductDimensions {
     length: Float
     width: Float
     height: Float
   }
   ```

2. **Generate input types**:
   ```graphql
   input ProductAttributesInput {
     color: String!
     size: ProductSize
     weight: Float
     dimensions: ProductDimensionsInput
     tags: [String!]
     features: [ProductFeatureInput!]
   }
   ```

3. **Generate filter types**:
   ```graphql
   input ProductAttributesFilter {
     color: StringFilter
     size: ProductSizeFilter
     weight: FloatFilter
     tags_contains: String
     tags_contains_all: [String!]
   }
   ```

## Technical Considerations

### 1. Type Mapping

| JSONB Schema Type | Elixir Type | PostgreSQL Cast | GraphQL Type |
|-------------------|-------------|-----------------|--------------|
| `:string` | `String.t()` | `text` | `String` |
| `:integer` | `integer()` | `integer` | `Int` |
| `:decimal` / `:float` | `Decimal.t()` / `float()` | `numeric` | `Float` |
| `:boolean` | `boolean()` | `boolean` | `Boolean` |
| `:date` | `Date.t()` | `date` | `Date` |
| `:datetime` | `DateTime.t()` | `timestamp` | `DateTime` |
| `:object` | `map()` | - | Custom Type |
| `:array` | `list()` | - | `[ItemType]` |

### 2. PostgreSQL JSONB Operators

| Operation | Operator | Example |
|-----------|----------|---------|
| Get field as text | `->>` | `data->>'name'` |
| Get field as JSON | `->` | `data->'nested'` |
| Get path as text | `#>>` | `data#>>'{a,b,c}'` |
| Get path as JSON | `#>` | `data#>'{a,b}'` |
| Contains | `@>` | `data @> '{"a":1}'` |
| Contained by | `<@` | `'{"a":1}' <@ data` |
| Key exists | `?` | `data ? 'key'` |
| Any key exists | `?\|` | `data ?\| array['a','b']` |
| All keys exist | `?&` | `data ?& array['a','b']` |

### 3. Index Recommendations

For optimal query performance, document recommended indexes:
```sql
-- GIN index for containment queries
CREATE INDEX idx_products_attributes ON products USING GIN (attributes);

-- B-tree index on specific extracted field
CREATE INDEX idx_products_color ON products ((attributes->>'color'));

-- Expression index with cast for numeric comparisons
CREATE INDEX idx_products_weight ON products (((attributes->>'weight')::numeric));
```

### 4. Migration Support

Consider adding a helper to generate Ecto migrations:
```elixir
SelectoMix.gen_jsonb_indexes(ProductDomain, :attributes)
# Generates migration with appropriate GIN and expression indexes
```

## Validation Rules

Support these validation rules in JSONB schemas:

```elixir
"field" => %{
  type: :string,
  required: true,              # Field must be present
  default: "value",            # Default value if not provided
  enum: ["a", "b", "c"],       # Allowed values
  min_length: 1,               # String min length
  max_length: 100,             # String max length
  pattern: ~r/^[A-Z]/,         # Regex pattern
  min: 0,                      # Numeric min
  max: 100,                    # Numeric max
  custom: &MyValidator.validate/1  # Custom validation function
}
```

## Error Handling

JSONB validation errors should include full paths:
```elixir
{:error, %SelectoUpdato.Error{
  type: :validation,
  message: "Validation failed",
  details: %{
    errors: [
      {["attributes", "dimensions", "length"], "must be greater than 0"},
      {["attributes", "color"], "is required"},
      {["attributes", "size"], "must be one of: small, medium, large"}
    ]
  }
}}
```

## Questions to Resolve

1. **Path separator**: Use dot notation (`attributes.color`) or bracket notation (`attributes[color]`)?
   - Recommendation: Dot notation for simplicity, matching JavaScript conventions

2. **Null handling**: How to distinguish between `null` value and missing field?
   - Recommendation: `nil` means missing, explicit `%{field: nil}` for null value

3. **Array operations**: What array filter operations to support?
   - `contains` - Array contains value
   - `contains_all` - Array contains all values
   - `contains_any` - Array contains any of values
   - `length` - Array length comparisons

4. **Partial updates**: How granular should path-based updates be?
   - Recommendation: Support arbitrary depth, generate `jsonb_set` calls

5. **Schema evolution**: How to handle schema changes over time?
   - Recommendation: Validation is optional; missing schema fields pass through

## Implementation Order

1. **Phase 1a**: Selecto JSONB filtering (basic `->>` and `@>` operators)
2. **Phase 1b**: Selecto JSONB selection (extracting fields)
3. **Phase 2a**: SelectoUpdato JSONB validation
4. **Phase 2b**: SelectoUpdato partial JSONB updates
5. **Phase 3a**: SelectoAbsinthe JSONB type generation
6. **Phase 3b**: SelectoAbsinthe JSONB filter generation

## Testing Strategy

Add test schemas and cases in `selecto_updato_test`:

1. **Schema**: `ProductWithAttributes` with comprehensive JSONB column
2. **Tests**:
   - Insert with valid JSONB data
   - Insert with invalid JSONB data (validation errors)
   - Update entire JSONB column
   - Update specific JSONB paths
   - Filter by JSONB fields (equality, comparison, contains)
   - Select specific JSONB paths
   - Nested object validation
   - Array validation
   - Enum validation

## Example End-to-End Usage

```elixir
# Domain definition
defmodule ProductDomain do
  def domain do
    %{
      name: "products",
      source: Product,
      columns: %{
        "id" => %{type: :integer},
        "name" => %{type: :string},
        "attributes" => %{
          type: :jsonb,
          schema: %{
            "color" => %{type: :string, required: true},
            "size" => %{type: :string, enum: ["S", "M", "L", "XL"]}
          }
        }
      }
    }
  end
end

# Insert with validation
SelectoUpdato.new(ProductDomain.domain())
|> SelectoUpdato.insert(%{
  name: "T-Shirt",
  attributes: %{color: "red", size: "M"}
})
|> SelectoUpdato.execute(Repo)

# Query with JSONB filter
Selecto.configure(ProductDomain.domain())
|> Selecto.filter({"attributes.color", "red"})
|> Selecto.filter({"attributes.size", %{in: ["M", "L"]}})
|> Selecto.select(["id", "name", "attributes.color"])
|> Selecto.execute(Repo)

# GraphQL query (auto-generated)
query {
  products(filter: {attributes: {color: {eq: "red"}}}) {
    id
    name
    attributes {
      color
      size
    }
  }
}
```
