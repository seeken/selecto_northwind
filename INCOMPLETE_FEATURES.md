# Incomplete Features Audit

This document tracks incomplete, stubbed, or placeholder features across the Selecto ecosystem. Last updated: 2026-01-14.

## Overview

| Library | High Priority | Medium Priority | Low Priority | Total | Completed |
|---------|--------------|-----------------|--------------|-------|-----------|
| Selecto (Core) | 4 | 4 | 2 | 10 | 10 |
| SelectoComponents (UI) | 3 | 7 | 8 | 18 | 11 |
| **Total** | **7** | **11** | **10** | **28** | **21** |

### Recently Completed (branch: feature/incomplete-features-audit)
- ✅ #1 Join/CTE Operations (selecto) - Dynamic joins at runtime
- ✅ #2 Through-Type Joins (selecto)
- ✅ #9 Set Operations Column Mapping (selecto) - Intelligent name-based and explicit column mapping
- ✅ #10 SQL Type System Enhancement (selecto) - New TypeSystem module with type inference
- ✅ #19 Filter Error Handling (selecto_components) - Robust error handling with enum validation
- ✅ #3 Non-Association Joins / Custom Joins (selecto)
- ✅ #4 Connection Pool Checkout (selecto) - Proper checkout/checkin/transaction support
- ✅ #5 Streaming Output (selecto) - Memory-efficient processing for large datasets
- ✅ #6 Multi-Argument Aggregate Functions (selecto)
- ✅ #7 Window Function Join Extraction (selecto)
- ✅ #8 Phoenix Helpers Query State (selecto) - Sort/filter/pagination state tracking
- ✅ #11 Filter Set Sharing (selecto_components)
- ✅ #12 Filter Set Export (selecto_components)
- ✅ #13 Date Range Comparison Shortcuts (selecto_components)
- ✅ #14 Router Event Handler Placeholders (selecto_components) - Full implementation
- ✅ #15 Bulk Actions Processing (selecto_components) - Handler system with callbacks
- ✅ #16 Inline Edit Validation (selecto_components)
- ✅ #17 Inline Edit Optimistic Update (selecto_components)
- ✅ #18 Quick Add Form Field Discovery (selecto_components) - Ecto schema introspection
- ✅ #20 Get All Row IDs (selecto_components) - Multi-source ID extraction

---

## Selecto (Core Library)

### High Priority

#### 1. Join/CTE Operations ✅ COMPLETED
- **File:** `vendor/selecto/lib/selecto.ex`, `vendor/selecto/lib/selecto/dynamic_join.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented dynamic join functions for runtime query building.
- **Implementation:**
  - `Selecto.join/3` - Enable domain-configured joins or add custom joins
  - `Selecto.join_parameterize/4` - Create parameterized instances of joins with different filters
  - `Selecto.join_subquery/4` - Join with another Selecto query as subquery
  - New `Selecto.DynamicJoin` module handles all dynamic join logic
- **Usage:**
  ```elixir
  # Enable a domain join
  selecto |> Selecto.join(:category)

  # Custom join
  selecto |> Selecto.join(:audit_log, source: "audit_logs", on: [...])

  # Parameterized join
  selecto |> Selecto.join_parameterize(:orders, "active", status: "active")
  ```

#### 2. Through-Type Joins ✅ COMPLETED
- **File:** `vendor/selecto/lib/selecto/schema/join.ex`
- **Lines:** 152-234
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented `expand_through_joins/7` that properly traverses `has_many :through` associations, generating intermediate joins automatically. Supports both 2-step through paths (e.g., `[:posts, :tags]`) and longer recursive paths.
- **Implementation:** Added detection in `normalize_joins/4` for associations with `through` key, which calls `expand_through_joins` to generate both the intermediate join and final join with proper parent references.

#### 3. Non-Association Joins (Custom Joins) ✅ COMPLETED
- **File:** `vendor/selecto/lib/selecto/schema/join.ex`
- **Lines:** 94-107, 236-257
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented custom joins that don't correspond to Ecto associations using `non_assoc: true` flag.
- **Implementation:**
  - Added pattern matching in `normalize_joins/4` for `%{non_assoc: true}` configurations
  - Implemented `configure_non_assoc/5` that builds join config from explicit source table, owner_key, related_key
  - Added `get_target_schema_for_non_assoc/2` for nested joins on custom joins
  - Supports optional `fields` and `filters` configuration
- **Usage:** Define join with `non_assoc: true, source: "table_name", owner_key: :id, related_key: :foreign_id`

#### 4. Connection Pool Checkout ✅ COMPLETED
- **File:** `vendor/selecto/lib/selecto/connection_pool.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented proper connection pool management functions.
- **Implementation:**
  - `checkout/2` - Manual connection checkout for multi-query operations
  - `checkin/2` - Return checked-out connection to pool
  - `with_connection/2` - Execute function with auto-checkout/checkin
  - `transaction/3` - Execute function within a database transaction
  - Fixed `execute_with_pool/5` to use Postgrex directly with pool
  - Added `execute_with_prepared_cache/5` for prepared statement caching
- **Usage:**
  ```elixir
  # Auto-managed connection
  Selecto.ConnectionPool.with_connection(pool, fn conn ->
    Postgrex.query!(conn, "SELECT * FROM users", [])
  end)

  # Transaction
  Selecto.ConnectionPool.transaction(pool, fn conn ->
    Postgrex.query!(conn, "INSERT INTO ...", [...])
    Postgrex.query!(conn, "UPDATE ...", [...])
  end)
  ```

---

### Medium Priority

#### 5. Streaming Output Format ✅ COMPLETED
- **File:** `vendor/selecto/lib/selecto/output/transformers/stream.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented comprehensive streaming transformations for large datasets.
- **Implementation:**
  - New `Selecto.Output.Transformers.Stream` module with full streaming support
  - `transform/5` - Main streaming transformation with configurable batch sizes
  - `transform_single/5` - Row-by-row streaming for simple transformations
  - `transform_chunked/5` - Yield results in chunks for pagination
  - `transform_to_io/6` - Stream directly to IO device/file
  - Supports inner formats: `:maps`, `:json`, `:csv`, `:raw`
  - Parallel batch processing option for performance
- **Usage:**
  ```elixir
  # Stream to maps
  {:ok, stream} = Selecto.execute(selecto, format: {:stream, :maps})
  Enum.each(stream, &process_row/1)

  # Stream CSV to file
  {:ok, stream} = Selecto.execute(selecto, format: {:stream, :csv})
  Enum.into(stream, File.stream!("output.csv"))
  ```

#### 6. Multi-Argument Aggregate Functions ✅ COMPLETED
- **File:** `vendor/selecto/lib/selecto/sql/functions.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented support for aggregate functions that take multiple arguments.
- **Implementation:** Added the following functions to `Selecto.SQL.Functions`:
  - `{:string_agg, field, delimiter}` - String aggregation with custom delimiter
  - `{:string_agg, field, delimiter, opts}` - With ORDER BY and DISTINCT support
  - `{:json_object_agg, key_field, value_field}` - JSON object aggregation
  - `{:jsonb_object_agg, key_field, value_field}` - JSONB object aggregation
  - `{:grouping, fields}` - GROUPING function for ROLLUP/CUBE operations
- **Usage:**
  ```elixir
  {:string_agg, "name", ", "}
  {:string_agg, "name", ", ", order_by: "name", distinct: true}
  {:jsonb_object_agg, "key_field", "value_field"}
  {:grouping, ["field1", "field2"]}
  ```

#### 7. Window Function Join Extraction ✅ COMPLETED
- **File:** `vendor/selecto/lib/selecto/builder/window.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented join extraction for window function fields.
- **Implementation:**
  - `extract_required_joins/2` now properly collects field references from partition_by, order_by, and arguments
  - Added `collect_field_references/3` to gather all fields from window spec
  - Added `find_join_for_field/2` to determine which join a field requires
  - Added `find_join_from_columns/2` to look up join requirements from column config
  - Handles both qualified (e.g., "category.name") and unqualified field names
- **Behavior:** Window functions that reference joined table fields now automatically include required joins

#### 8. Phoenix Helpers (Query State Tracking) ✅ COMPLETED
- **File:** `vendor/selecto/lib/selecto/phoenix_helpers.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented full query state tracking for Phoenix/LiveView integration.
- **Implementation:**
  - `get_current_page/2` - Extract current page from selecto state
  - `get_per_page/2` - Get items per page setting
  - `get_current_sort/1` - Get current sort field/direction
  - `get_current_filter_value/2` - Get value for specific filter
  - `put_pagination/3` - Set page/per_page with automatic offset calculation
  - `remove_filter/2` - Remove filter by field name
  - Added public helpers: `get_filters/1`, `get_sort/1`, `is_filtered?/2`, `is_sorted?/2`
  - Added `toggle_sort/2` for UI sort toggling (asc → desc → none)
  - Added `clear_filters/1` and `reset_query/1` for bulk operations
- **Usage:**
  ```elixir
  # Check current state
  current_filters = Selecto.PhoenixHelpers.get_filters(selecto)
  {sort_field, direction} = Selecto.PhoenixHelpers.get_sort(selecto)

  # Toggle sort in UI
  selecto = Selecto.PhoenixHelpers.toggle_sort(selecto, "name")
  ```

---

### Lower Priority

#### 9. Set Operations Column Mapping ✅ COMPLETED
- **File:** `vendor/selecto/lib/selecto/set_operations.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented intelligent column mapping for UNION/INTERSECT/EXCEPT operations.
- **Implementation:**
  - `apply_column_mapping/3` now supports three modes:
    1. No mapping (nil): Attempts intelligent name-based matching with fallback to position
    2. List mapping: `[{"left_col", "right_col"}, ...]` for explicit column pairing
    3. Map mapping: `%{"left_col" => "right_col"}` alternative syntax
  - `try_name_based_mapping/2` matches columns by exact name or common patterns
  - `build_alternative_names/1` generates alternative names (e.g., `full_name` → `name`, `email_address` → `email`)
  - `normalize_name/1` handles case-insensitive comparison and special characters
  - `find_matching_right_column/2` provides fallback for unmatched columns
- **Usage:**
  ```elixir
  # Automatic name-based matching
  Selecto.union(customers_query, vendors_query)

  # Explicit column mapping
  Selecto.union(customers_query, vendors_query,
    column_mapping: [{"name", "company_name"}, {"email", "contact_email"}]
  )
  ```

#### 10. SQL Type System Enhancement ✅ COMPLETED
- **File:** `vendor/selecto/lib/selecto/type_system.ex` (NEW), `vendor/selecto/lib/selecto.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented comprehensive type inference system for SQL expressions.
- **Implementation:**
  - New `Selecto.TypeSystem` module with complete type inference for:
    - Literals (integer, float, boolean, string, date/time, UUID)
    - Field references (via FieldResolver)
    - Aggregate functions (COUNT, SUM, AVG, MIN, MAX, STRING_AGG, etc.)
    - Scalar functions (CONCAT, UPPER, ABS, ROUND, etc.)
    - CASE expressions, COALESCE, GREATEST, LEAST
    - Window functions
  - Type categories: `:numeric`, `:string`, `:boolean`, `:datetime`, `:json`, `:array`, `:binary`, `:uuid`
  - `compatible?/2` for type compatibility checking
  - `coerce_types/3` for determining result types in operations
  - `type_category/1` for grouping types
  - Public API exposed via main `Selecto` module
- **Usage:**
  ```elixir
  # Infer expression type
  {:ok, :bigint} = Selecto.infer_type(selecto, {:count, "*"})
  {:ok, :decimal} = Selecto.infer_type(selecto, {:sum, "price"})
  {:ok, :string} = Selecto.infer_type(selecto, "product_name")

  # Check type compatibility
  true = Selecto.types_compatible?(:integer, :decimal)
  false = Selecto.types_compatible?(:string, :boolean)
  ```

---

## SelectoComponents (UI Library)

### High Priority

#### 11. Filter Set Sharing ✅ COMPLETED
- **File:** `vendor/selecto_components/lib/selecto_components/filter/filter_sets.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented shareable URL generation for filter configurations.
- **Implementation:**
  - `generate_share_data/2` now encodes filters as compressed base64 URL-safe string
  - Added `decode_shared_filters/1` to decode shared filter URLs
  - Uses gzip compression for compact URLs
  - Includes filter set name and metadata in encoded data
- **Usage:** Share URLs contain `?filters=<encoded>` parameter that can be decoded on page load

#### 12. Filter Set Export ✅ COMPLETED
- **File:** `vendor/selecto_components/lib/selecto_components/filter/filter_sets.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented JSON export/import for filter configurations.
- **Implementation:**
  - `export_filter_set/2` serializes filter set to JSON with schema version and timestamp
  - Added `import_filter_set/2` to import from JSON string
  - Includes version field for future schema migrations
  - Validates imported data structure
- **Export Format:**
  ```json
  {
    "version": "1.0",
    "exported_at": "2026-01-13T...",
    "filter_set": { "name": "...", "filters": [...] }
  }
  ```

#### 13. Date Range Comparison Shortcuts ✅ COMPLETED
- **File:** `vendor/selecto_components/lib/selecto_components/form/datetime_filters.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented proper period comparison using OR groups.
- **Implementation:** All four comparison shortcuts now return OR group configurations:
  - `ytd_vs_last` - Returns OR group with current YTD and same period last year
  - `qtd_vs_last` - Returns OR group with current QTD and same period last quarter
  - `mtd_vs_last` - Returns OR group with current MTD and same period last month
  - `mtd_vs_last_year` - Returns OR group with current MTD and same month last year
- **Output Format:**
  ```elixir
  %{
    "comp" => "OR",
    "groups" => [
      [current_period_filters],
      [comparison_period_filters]
    ]
  }
  ```

---

### Medium Priority

#### 14. Router Event Handler Placeholders ✅ COMPLETED
- **File:** `vendor/selecto_components/lib/selecto_components/router.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented all router event handlers with full functionality.
- **Implementation:**
  - `handle_save_view/2` - Saves view config to saved_view_module or state
  - `handle_tree_drop/2` - Drag-and-drop filter reordering with position support
  - `handle_filter_remove/2` - Remove filter by UUID from configuration
  - `handle_agg_add_filters/2` - Drill-down from aggregate cells, switches to detail view
  - `handle_list_picker_remove/4` - Remove item from selected/group_by/aggregate lists
  - `handle_list_picker_move/5` - Reorder items with order tracking
  - `handle_list_picker_add/4` - Add items with UUID and order assignment
  - `apply_filters/2` - Full filter application with all comparison operators
  - Added helper functions for filter manipulation
- **Supported Comparisons:** `=`, `!=`, `>`, `>=`, `<`, `<=`, `like`, `ilike`, `in`, `not_in`, `is_null`, `is_not_null`, `AND`, `OR`

#### 15. Bulk Actions Processing ✅ COMPLETED
- **File:** `vendor/selecto_components/lib/selecto_components/enhanced_table/bulk_actions.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented proper bulk action processing with callback support.
- **Implementation:**
  - `process_batch/2` now supports three handler modes:
    1. Function handler: `%{handler: fn batch_ids -> ... end}`
    2. Module/function handler: `%{handler: {MyModule, :process_batch}}`
    3. Parent notification: Sends `{:bulk_action_process_batch, action_id, batch_ids}` to parent
  - Removed simulation sleep - real processing via callbacks
- **Usage:**
  ```elixir
  # Define action with custom handler
  %{
    id: "delete",
    label: "Delete",
    handler: fn batch_ids ->
      Repo.delete_all(from r in Record, where: r.id in ^batch_ids)
      {:ok, batch_ids}
    end
  }

  # Or handle in parent LiveView
  def handle_info({:bulk_action_process_batch, "delete", batch_ids}, socket) do
    # Process deletion
    {:noreply, socket}
  end
  ```

#### 16. Inline Edit Validation ✅ COMPLETED
- **File:** `vendor/selecto_components/lib/selecto_components/enhanced_table/inline_edit.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented comprehensive cell validation based on field type.
- **Implementation:**
  - `validate_cell_value/3` now extracts field config and validates by type
  - Added `validate_by_config/2` with type-specific validation
  - Supports: `:string`, `:integer`, `:float`, `:decimal`, `:boolean`, `:date`, `:datetime`, `:email`
  - Validates required fields, max/min length, format patterns
  - Returns `{:ok, coerced_value}` or `{:error, reason}`
- **Type Coercion:** Automatically coerces string inputs to appropriate types (e.g., "123" → 123 for integers)

#### 17. Inline Edit Optimistic Update ✅ COMPLETED
- **File:** `vendor/selecto_components/lib/selecto_components/enhanced_table/inline_edit.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented optimistic UI updates for inline editing.
- **Implementation:**
  - `apply_optimistic_update/3` now updates the row data in socket assigns
  - Extracts row_id and field_name from cell_id
  - Updates the specific field in the matching row
  - Works with both list and stream-based row storage
- **Behavior:** UI immediately reflects changes without waiting for server confirmation

#### 18. Quick Add Form Field Discovery ✅ COMPLETED
- **File:** `vendor/selecto_components/lib/selecto_components/forms/quick_add.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented comprehensive schema introspection for form field generation.
- **Implementation:**
  - `build_fields_from_schema/1` now handles:
    1. Ecto schema modules - Uses `__schema__/1` to extract fields and types
    2. Selecto domain column configs - Extracts from columns map
  - Added `build_field_config/3` for Ecto schema field processing
  - Added `build_field_from_column/2` for Selecto column processing
  - Type mapping via `ecto_type_to_form_type/1` and `selecto_type_to_form_type/1`
  - Supports: `:string`, `:integer`, `:float`, `:decimal`, `:boolean`, `:date`, `:time`, `:datetime`, arrays, maps, enums
  - Auto-detects required fields from foreign key associations
  - Excludes primary keys and timestamp fields automatically
- **Supported Input Types:** `:text`, `:number`, `:boolean`, `:date`, `:select`, `:textarea`

#### 19. Filter Error Handling ✅ COMPLETED
- **File:** `vendor/selecto_components/lib/selecto_components/helpers/filters.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented robust error handling for filter processing with enum validation.
- **Implementation:**
  - Refactored `filter_recurse/3` with try/rescue error handling
  - `process_single_filter/3` wraps individual filter processing with error capture
  - `process_column_filter/3` handles column lookup and type-based filter building
  - `build_typed_filter/3` builds filters based on column type with proper error handling
  - `safe_make_num_filter/2` and `safe_make_date_filter/1` wrap filter creation with error capture
  - `validate_enum_value/2` validates enum values against allowed mappings:
    - Supports map format: `%{mappings: %{key1: "label1", key2: "label2"}}`
    - Supports list format: `[{:key1, "label1"}, {:key2, "label2"}]`
    - Returns descriptive error messages for invalid values
  - `find_column/2` improved column lookup by key, colid, or name
  - Unknown column types now treated as strings with debug logging
  - Errors are logged but don't crash filter chain - invalid filters are skipped
- **Behavior:**
  - Invalid filters are skipped with warning log instead of crashing
  - Enum values are validated against configured mappings
  - Type-specific errors (invalid date, invalid number) are captured and reported
  - Unknown column types fall back to string filter handling

#### 20. Get All Row IDs for Bulk Actions ✅ COMPLETED
- **File:** `vendor/selecto_components/lib/selecto_components/enhanced_table/bulk_actions.ex`
- **Status:** ✅ Implemented in branch `feature/incomplete-features-audit`
- **Description:** Implemented multi-source row ID extraction for bulk selection.
- **Implementation:**
  - `get_all_row_ids/1` now extracts IDs from multiple sources:
    1. Explicit `all_row_ids` assign
    2. `rows` list (maps with id field)
    3. `query_results` Selecto format (rows + columns)
    4. Phoenix `streams` data structure
    5. Parent component request via `{:request_all_row_ids, pid}` message
  - Added `extract_ids_from_rows/1` for list/map extraction
  - Added `extract_ids_from_query_results/1` for Selecto format
  - Added `extract_ids_from_stream/1` for Phoenix streams
  - Added public `set_all_row_ids/2` for parent components to push IDs
- **ID Fields:** Checks `:id`, `"id"`, `:_id`, `"_id"`, `"pk"`, `"primary_key"`

---

### Lower Priority (Dashboard/Widget Features)

These features are part of the dashboard system which may be considered experimental or optional:

#### 21. Widget Data Fetching
- **File:** `vendor/selecto_components/lib/selecto_components/dashboard/widget_registry.ex`
- **Lines:** 336-338
- **Status:** Returns mock data
- **Description:** `fetch_data/2` returns placeholder data instead of querying real sources
- **Suggested Fix:** Implement data source configuration and actual query execution

#### 22. Metric Display Sample Data
- **File:** `vendor/selecto_components/lib/selecto_components/dashboard/metric_display.ex`
- **Lines:** 342, 358
- **Status:** Generates sample data
- **Description:** `generate_sample_metrics/1` creates fake metrics for display
- **Suggested Fix:** Connect to actual metric calculation from query results

#### 23. Layout Manager Widget Content
- **File:** `vendor/selecto_components/lib/selecto_components/dashboard/layout_manager.ex`
- **Lines:** 449-451
- **Status:** Returns placeholder content
- **Description:** `render_widget_content/1` returns placeholder instead of actual widget
- **Suggested Fix:** Implement widget type dispatch and rendering

#### 24. Layout Persistence
- **File:** `vendor/selecto_components/lib/selecto_components/dashboard/layout_manager.ex`
- **Lines:** 310, 318, 350
- **Status:** Storage functions return errors
- **Description:** `save_layout_to_storage/1` and `load_layout_from_storage/0` don't persist
- **Suggested Fix:** Implement storage backend (database, localStorage via hooks, etc.)

#### 25. Custom Widget Registration
- **File:** `vendor/selecto_components/lib/selecto_components/dashboard/widget_registry.ex`
- **Lines:** 197
- **Status:** Unused parameter
- **Description:** `register_custom_widget/1` doesn't use the definition parameter
- **Suggested Fix:** Implement widget registration in ETS or module attribute

#### 26. Subselect Builder
- **File:** `vendor/selecto_components/lib/selecto_components/subselect_builder.ex`
- **Lines:** 142
- **Status:** Returns placeholder structure
- **Description:** Subquery building returns placeholder instead of actual subselect
- **Suggested Fix:** Implement subquery generation that integrates with Selecto core

#### 27. Slot Provider
- **File:** `vendor/selecto_components/lib/selecto_components/slots/slot_provider.ex`
- **Lines:** 181, 191
- **Status:** Returns defaults
- **Description:** Slot registration and retrieval use process dictionary with fallback to defaults
- **Suggested Fix:** Implement proper slot registration system if custom slots are needed

#### 28. Responsive Column Selection
- **File:** `vendor/selecto_components/lib/selecto_components/enhanced_table/responsive_wrapper.ex`
- **Lines:** 367
- **Status:** Simple heuristic
- **Description:** Mobile column selection uses basic priority-based selection
- **Note:** This may be acceptable as-is; enhancement would be nice-to-have
- **Suggested Fix:** Implement smarter column selection based on data importance or user preferences

---

## Implementation Priority Recommendations

### Phase 1: Core Functionality (High Impact)
1. **Through-Type Joins** (#2) - Blocks many-to-many relationship usage
2. **Filter Set Export/Share** (#11, #12) - User-requested features
3. **Date Range Comparisons** (#13) - Advertised but not working

### Phase 2: Developer Experience
4. **Custom Joins** (#3) - Enables advanced query patterns
5. **Router Event Handlers** (#14) - Complete the event handling system
6. **Inline Edit Validation** (#16) - Data integrity

### Phase 3: Advanced Features
7. **Join/CTE Operations** (#1) - Power user features
8. **Multi-Argument Aggregates** (#6) - SQL completeness
9. **Streaming Output** (#5) - Large dataset handling

### Phase 4: Polish
10. **Bulk Actions** (#15, #20) - Complete the bulk operations system
11. **Quick Add Forms** (#18) - Schema-aware form generation
12. **Dashboard Features** (#21-28) - If dashboard is a priority

---

## Notes

- Some "incomplete" features may be intentionally deferred or represent future roadmap items
- The router.ex placeholders may be superseded by implementations in form.ex
- Dashboard features appear to be in early development stage
- Connection pool features may not be needed if all queries go through Ecto Repo

## Contributing

When implementing any of these features:
1. Add tests covering the new functionality
2. Update relevant documentation
3. Consider backwards compatibility
4. Update this document to mark items as complete
