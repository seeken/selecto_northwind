# Product Domain

Generated from a normalized Selecto domain artifact.

## Artifact

| Key | Value |
| --- | --- |
| Path | priv/selecto/product.normalized.json |
| Format | selecto.normalized_domain v1 |
| Domain module | SelectoNorthwind.SelectoDomains.ProductDomain |
| Schema version | 1 |

## Sections

| Class | Sections |
| --- | --- |
| canonical | default_selected, filters, functions, joins, name, query_members, schema_version, schemas, source |
| projection | pagination, retarget, subfilters, window_functions |
| proposed | (none) |
| unknown | (none) |

## Counts

| Item | Count |
| --- | --- |
| source fields | 13 |
| source columns | 13 |
| schemas | 6 |
| joins | 6 |
| filters | 2 |
| functions | 0 |
| query members | 0 |
| published views | 0 |
| detail actions | 0 |
| write operations | 0 |
| write fields | 0 |
| write transitions | 0 |
| write validations | 0 |
| write constraints | 0 |
| actions | 0 |
| capabilities | 0 |
| source relationships | 0 |
| choice sources | 0 |

## Source

| Key | Value |
| --- | --- |
| Table | products |
| Primary key | id |
| Fields | id, product_name, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued, attributes, supplier_id, category_id, inserted_at, updated_at |

### Source Columns

| Field | Type | Label |
| --- | --- | --- |
| attributes | jsonb |  |
| category_id | integer |  |
| discontinued | boolean |  |
| id | integer |  |
| inserted_at | naive_datetime |  |
| product_name | string |  |
| quantity_per_unit | string |  |
| reorder_level | integer |  |
| supplier_id | integer |  |
| unit_price | decimal |  |
| units_in_stock | integer |  |
| units_on_order | integer |  |
| updated_at | naive_datetime |  |

## Schemas

| Schema | Table | Columns |
| --- | --- | --- |
| category | categorys | 0 |
| flag_type | flag_types | 0 |
| order_detail | order_details | 0 |
| product_flag | product_flags | 0 |
| supplier | suppliers | 0 |
| tag | tags | 0 |

## Registries

### Joins

| Id | Label | Kind | Target |
| --- | --- | --- | --- |
| category | Category | inner |  |
| flag_types | Flag Types | left |  |
| order_details | Order Details | left |  |
| product_flags | Product Flags | left |  |
| supplier | Supplier | inner |  |
| tags | Tags | left |  |

### Filters

| Id | Label | Kind | Target |
| --- | --- | --- | --- |
| category_id | Category Id | integer |  |
| discontinued | Discontinued | boolean |  |

## Query Members

| Group | Member | Label | Kind |
| --- | --- | --- | --- |

## Diagnostics

| Scope | Errors | Warnings | Error Codes | Warning Codes |
| --- | ---: | ---: | --- | --- |
| Artifact | 0 | 1 | (none) | projection_sections |
| Current | 0 | 1 | (none) | projection_sections |

