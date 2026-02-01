# Test Coverage Analysis

## Current State

The project has **38 source files** but only **3 test files** with **5 total test cases**.

### Existing Tests

| Test File | Tests | Coverage |
|-----------|-------|----------|
| `page_controller_test.exs` | 1 | `GET /` returns 200 |
| `error_html_test.exs` | 2 | 404/500 HTML rendering |
| `error_json_test.exs` | 2 | 404/500 JSON rendering |

The `DataCase` test helper (with `errors_on/1` for changeset testing and SQL sandbox) is
configured but completely unused -- no data-layer test exists.

---

## Gap Analysis and Recommendations

### 1. Schema Changeset Validations (Highest Priority)

**0 of 19 schemas have test coverage.** There are 105+ validation rules that are untested.

Priority schemas (richest validation logic):

- **`Catalog.Product`** -- 10 cast fields, `validate_required`, 4 `validate_number` constraints
  (non-negative prices/quantities), 2 `foreign_key_constraint` checks, length validations.
- **`Sales.Customer`** -- Custom string primary key, `validate_length(:customer_id, is: 5)`
  (exact length), `unique_constraint`, 12 field length validations.
- **`Sales.OrderDetail`** -- Composite primary key, `validate_number(:discount, >= 0, < 1)`
  (half-open range), all fields required, FK constraints.
- **`Sales.Order`** -- FK references across contexts (customer, employee, shipper via `ship_via`),
  date fields, freight validation.
- **`Hr.Employee`** -- Self-referential `belongs_to :manager` / `has_many :subordinates`,
  13 length validations, FK constraint on `reports_to`.
- **`Support.Comment`** -- Polymorphic pattern with
  `validate_inclusion(:commentable_type, ["Product", "Order", "Customer"])`.
- **`Support.FlagType`** -- Two `validate_inclusion` rules, compound unique constraint on
  `[:entity_type, :name]`.

#### What to test per schema

- Valid attrs produce a valid changeset
- Missing required fields produce errors
- Values exceeding length limits are rejected
- Number validations reject out-of-range values (negative prices, discount >= 1, etc.)
- Unique constraints fail on duplicates (requires database, use `DataCase`)
- FK constraints fail on invalid references

### 2. Business Logic Functions (High Priority)

Two functions have actual logic and zero tests:

- **`Sales.OrderDetail.total_price/1`** -- Computes
  `(unit_price * quantity) - (unit_price * quantity * discount)` using Decimal arithmetic.
  Test with zero discount, fractional discount, edge cases like quantity=1, and verify
  Decimal precision.
- **`Hr.Employee.full_name/1`** -- Returns `"#{first_name} #{last_name}"`. Simple but should
  have a test to lock in the contract.

### 3. Controller Route Coverage (Medium-High Priority)

Only `GET /` is tested out of 7 routes. Missing:

- `GET /tutorial` -- TutorialController.index
- `GET /postgrex_tutorial` -- TutorialController.postgrex_tutorial
- `GET /customers_selecto` -- "coming soon" with flash
- `GET /products_selecto` -- "coming soon" with flash
- `GET /orders_selecto` -- "coming soon" with flash
- `GET /analytics` -- "coming soon" with flash

Verify each returns 200, renders the correct template, and for "coming soon" routes verify
the flash message and `page_title` assign.

### 4. Seeder Logic (Medium Priority)

`NorthwindSeeder` is a substantial module (29KB) with untested logic:

- **`seed_all/1`** -- Transactional full-database seeding
- **`seed_orders/1`** -- Fake order generation with deterministic RNG
- **`clear_all/0`** -- FK-safe deletion and sequence reset
- **`generate_scattered_timestamp/2`** -- Deterministic timestamp generation

Key tests:
- `seed_master_data/0` inserts into all master tables
- `seed_orders/1` creates expected order/detail counts
- `seed_orders/1` returns `{:error, :missing_master_data}` without master data
- `clear_all/0` removes all records
- `generate_scattered_timestamp/2` is deterministic (same input = same output)

### 5. Schema Association Integrity (Medium Priority)

40+ associations including complex patterns:

- Cross-context: `Order` -> `Customer` (Sales), `Employee` (HR), `Shipper` (Sales via `ship_via`)
- Self-referential: `Employee.manager` / `Employee.subordinates`
- String foreign keys: `Customer.customer_id`, `Territory.territory_id`
- Polymorphic: `Comment` with `commentable_type` + `commentable_id`
- EAV: `FlagType` + `ProductFlag`
- Many-to-many joins: `ProductTag`, `EmployeeTerritory`, `CustomerCustomerDemo`

Test by inserting parent records, creating children with associations, verifying preloads.

### 6. Existing Test Depth (Lower Priority)

Current 5 tests only cover happy paths:
- `page_controller_test.exs` should verify navigation links and structural elements
- Error tests could cover additional status codes (403, 422) for the catch-all render function

---

## Suggested Test File Structure

```
test/
├── selecto_northwind/
│   ├── catalog/
│   │   ├── product_test.exs
│   │   ├── category_test.exs
│   │   ├── supplier_test.exs
│   │   └── tag_test.exs
│   ├── sales/
│   │   ├── customer_test.exs
│   │   ├── order_test.exs
│   │   └── order_detail_test.exs
│   ├── hr/
│   │   └── employee_test.exs
│   ├── support/
│   │   ├── comment_test.exs
│   │   └── flag_type_test.exs
│   └── seeds/
│       └── northwind_seeder_test.exs
├── selecto_northwind_web/
│   └── controllers/
│       ├── page_controller_test.exs        # expand existing
│       ├── tutorial_controller_test.exs    # new
│       ├── error_html_test.exs             # existing
│       └── error_json_test.exs             # existing
└── support/
    ├── conn_case.ex
    └── data_case.ex
```

## Summary

| Area | Current | Priority | Effort |
|------|---------|----------|--------|
| Schema changesets (19 schemas, 105+ validations) | 0% | Highest | Medium |
| Business logic (`total_price`, `full_name`) | 0% | High | Low |
| Controller routes (5 of 7 untested) | 14% | Medium-High | Low |
| Seeder logic (5 public functions) | 0% | Medium | Medium |
| Association integrity (40+ associations) | 0% | Medium | High |
| Existing test depth (happy-path only) | Minimal | Lower | Low |

The most impactful first step: add changeset tests for `Product`, `Customer`, `OrderDetail`,
and `Employee` -- the schemas with the richest validation logic and most likely to catch
regressions.
