# Incomplete Features Audit

This document tracks incomplete, stubbed, or placeholder features across the Selecto ecosystem. Last updated: 2026-01-13.

## Overview

| Library | High Priority | Medium Priority | Low Priority | Total | Completed |
|---------|--------------|-----------------|--------------|-------|-----------|
| Selecto (Core) | 4 | 4 | 2 | 10 | 3 |
| SelectoComponents (UI) | 3 | 7 | 8 | 18 | 5 |
| **Total** | **7** | **11** | **10** | **28** | **8** |

### Recently Completed (branch: feature/incomplete-features-audit)
- ✅ #2 Through-Type Joins (selecto)
- ✅ #3 Non-Association Joins / Custom Joins (selecto)
- ✅ #6 Multi-Argument Aggregate Functions (selecto)
- ✅ #11 Filter Set Sharing (selecto_components)
- ✅ #12 Filter Set Export (selecto_components)
- ✅ #13 Date Range Comparison Shortcuts (selecto_components)
- ✅ #16 Inline Edit Validation (selecto_components)
- ✅ #17 Inline Edit Optimistic Update (selecto_components)

---

## Selecto (Core Library)

### High Priority

#### 1. Join/CTE Operations
- **File:** `vendor/selecto/lib/selecto.ex`
- **Lines:** 290-313
- **Status:** Commented out
- **Description:** Multiple join and CTE (Common Table Expression) functions are defined but commented out:
  ```elixir
  # def join(selecto_struct, join_id, options \\ [])
  # def join_paramterize(selecto_struct, join_id, parameter, options)
  # def join(selecto_struct, join_id, join_selecto, options \\ [])
  # def with(selecto_struct, cte_name, cte, params, options \\ [])
  # def with(selecto_struct, cte_name, cte_selecto, options \\ [])
  # def on_with(selecto_struct, cte_name, fn...)
  ```
- **Impact:** Users cannot programmatically add joins or CTEs to queries at runtime
- **Suggested Fix:** Implement join/CTE builder functions that modify the selecto struct and integrate with the SQL builder

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

#### 4. Connection Pool Checkout
- **File:** `vendor/selecto/lib/selecto/connection_pool.ex`
- **Lines:** 324-326
- **Status:** Returns `{:error, :not_implemented}`
- **Description:** The `checkout_connection/1` function is stubbed:
  ```elixir
  # TODO: Implement proper connection checkout using the correct DBConnection API
  defp checkout_connection(_pool) do
    {:error, :not_implemented}
  end
  ```
- **Impact:** Connection pool management for direct database connections doesn't work
- **Note:** This may be intentional if all queries go through Ecto's Repo, but limits advanced use cases
- **Suggested Fix:** Implement using `DBConnection.checkout/2` or document that this feature is not supported

---

### Medium Priority

#### 5. Streaming Output Format
- **File:** `vendor/selecto/lib/selecto/output/formats.ex`
- **Lines:** 89-91
- **Status:** Returns error
- **Description:** Streaming output transformation is not implemented:
  ```elixir
  # TODO: Implement streaming transformer
  defp transform_format({:stream, _inner_format}, _columns, _rows, _aliases) do
    {:error, "Streaming output not yet implemented"}
  end
  ```
- **Impact:** Large result sets cannot be streamed for memory-efficient processing
- **Suggested Fix:** Implement using Elixir Streams to lazily transform rows

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

#### 7. Window Function Join Extraction
- **File:** `vendor/selecto/lib/selecto/builder/window.ex`
- **Lines:** 243
- **Status:** Returns empty list placeholder
- **Description:** When window functions reference fields from joined tables, the necessary joins are not automatically added:
  ```elixir
  # TODO: Implement join extraction for fields that require joins
  defp extract_joins_from_window(_window_config, _domain) do
    []
  end
  ```
- **Impact:** Window functions that partition or order by joined fields may fail or produce incorrect results
- **Suggested Fix:** Parse window function configuration and extract required joins similar to how SELECT fields are handled

#### 8. Phoenix Helpers (Query State Tracking)
- **File:** `vendor/selecto/lib/selecto/phoenix_helpers.ex`
- **Lines:** 295-318
- **Status:** Placeholder stubs
- **Description:** Several helper functions for Phoenix/LiveView integration are stubs:
  ```elixir
  defp get_current_sort(_selecto), do: nil
  defp get_current_filter_value(_selecto, _field), do: nil
  defp remove_filter(selecto, _field), do: selecto  # Does nothing
  ```
- **Impact:** LiveView components cannot easily introspect current query state for UI rendering
- **Suggested Fix:** Store sort/filter state in selecto struct metadata and implement accessor functions

---

### Lower Priority

#### 9. Set Operations Column Mapping
- **File:** `vendor/selecto/lib/selecto/set_operations.ex`
- **Lines:** 228
- **Status:** Falls back to position-based
- **Description:** Column mapping for UNION/INTERSECT/EXCEPT operations uses position-based pairing instead of intelligent mapping
- **Impact:** Columns must be in exact order across all queries in set operations
- **Suggested Fix:** Implement column name matching or explicit mapping configuration

#### 10. SQL Type System Enhancement
- **File:** `vendor/selecto/lib/selecto/builder/sql/select.ex`
- **Lines:** 4, 789
- **Status:** TODO comments
- **Description:** Two related issues:
  - Line 4: `### TODO alter prep_selector to return the data type`
  - Line 789: `# TODO - other data types- float, decimal`
- **Impact:** Type coercion and validation is limited; some numeric operations may not work correctly
- **Suggested Fix:** Thread type information through the selector preparation pipeline

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

#### 14. Router Event Handler Placeholders
- **File:** `vendor/selecto_components/lib/selecto_components/router.ex`
- **Lines:** 107-213
- **Status:** Multiple placeholder functions
- **Description:** Several event handlers return `{:ok, state}` without implementation:

  | Function | Line | Purpose |
  |----------|------|---------|
  | `handle_save_view/2` | 107-111 | Persist view configuration |
  | `handle_tree_drop/2` | 172-175 | Drag-and-drop filter reordering |
  | `handle_filter_remove/2` | 178-181 | Remove filter from configuration |
  | `handle_agg_add_filters/2` | 184-188 | Drill-down from aggregate cells |
  | `handle_list_picker_remove/4` | 191-194 | Remove item from list |
  | `handle_list_picker_move/5` | 197-200 | Reorder list items |
  | `handle_list_picker_add/4` | 203-206 | Add item to list |
  | `apply_filters/2` | 209-213 | Apply filters to query |

- **Impact:** These features don't work when using the router-based event handling pattern
- **Note:** Some functionality may be implemented directly in `form.ex` instead
- **Suggested Fix:** Either implement these handlers or remove them if functionality exists elsewhere

#### 15. Bulk Actions Processing
- **File:** `vendor/selecto_components/lib/selecto_components/enhanced_table/bulk_actions.ex`
- **Lines:** 403-413
- **Status:** Simulated with sleep
- **Description:** Batch processing is simulated rather than implemented:
  ```elixir
  defp process_batch(action, batch) do
    # For now, simulate processing
    Process.sleep(500)
    batch_ids = Enum.map(batch, & &1.id)
    {:ok, batch_ids}
  end
  ```
- **Impact:** Bulk actions (delete, export, etc.) don't actually perform operations
- **Suggested Fix:** Implement callback system that allows parent components to define action handlers

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

#### 18. Quick Add Form Field Discovery
- **File:** `vendor/selecto_components/lib/selecto_components/forms/quick_add.ex`
- **Lines:** 484-495
- **Status:** Returns hardcoded examples
- **Description:** Schema field extraction returns dummy data:
  ```elixir
  defp build_fields_from_schema(_schema) do
    # For now, return example fields
    [
      %{name: :title, type: :string, required: true},
      %{name: :description, type: :text, required: false},
      # ...
    ]
  end
  ```
- **Impact:** Quick add forms don't adapt to actual schema structure
- **Suggested Fix:** Use `schema.__schema__(:fields)` and `__schema__(:type, field)` to introspect fields

#### 19. Filter Error Handling
- **File:** `vendor/selecto_components/lib/selecto_components/helpers/filters.ex`
- **Lines:** 252, 346
- **Status:** TODO comments
- **Description:** Two error handling gaps:
  - Line 252: `#### TODO handle errors` in `filter_recurse/3`
  - Line 346: `# TODO check selected against enum_conf.mappings!` for enum validation
- **Impact:** Invalid filter configurations may cause cryptic errors or silent failures
- **Suggested Fix:** Add try/rescue with user-friendly error messages; validate enum values against allowed mappings

#### 20. Get All Row IDs for Bulk Actions
- **File:** `vendor/selecto_components/lib/selecto_components/enhanced_table/bulk_actions.ex`
- **Lines:** 416-419
- **Status:** Returns empty list or examples
- **Description:** Cannot retrieve all row IDs for "select all" functionality:
  ```elixir
  defp get_all_row_ids(socket) do
    # This would get IDs from the parent component
    socket.assigns[:all_row_ids] || []
  end
  ```
- **Impact:** "Select all" in bulk actions doesn't work properly
- **Suggested Fix:** Implement communication with parent component or execute count query

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
