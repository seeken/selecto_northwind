# SelectoNorthwind

`selecto_northwind` is a Phoenix demo app for the Selecto ecosystem, using the classic Northwind dataset to show generated data exploration UIs in action.

## Quick Start

Prerequisites:

- Elixir `~> 1.18`
- PostgreSQL 12+
- Node.js

Set up and run the app:

```bash
git clone <repo-url>
cd selecto_northwind
mix setup
mix phx.server
```

Then open:

- `http://localhost:4000` for the demo app
- `http://localhost:4000/tutorial` for the step-by-step tutorial

`mix setup` installs dependencies, creates the database, runs migrations, seeds Northwind data,
installs npm packages when `assets/package.json` is present, and builds assets.

## What You Get

The tutorial walks through generating Selecto domains and LiveViews over a realistic sample dataset, including:

- catalog data such as products, suppliers, categories, and tags
- sales data such as customers, orders, and shippers
- HR and geography relationships for more complex join patterns
- overlay-driven detail modals, saved filter sets, and saved view column presets
- LiveDashboard integration, saved_view_configs, and parameterized join validation

## Useful Commands

```bash
mix phx.server
iex -S mix phx.server
mix test
mix precommit
mix ecto.reset
```

## Completed tutorial rerun — 2026-09-09

Branch: `tutorial/northwind-rerun-20260909`, starting at `5661424`.
Followed the Ecto tutorial steps 0–9 with released Hex packages: Selecto 0.4.8,
PostgreSQL adapter 0.4.5, Components 0.4.9, and Mix generators 0.4.7.

Run `PORT=4199 mise exec -- mix phx.server`, then open
[Products](http://localhost:4199/products_selecto),
[Customers](http://localhost:4199/customers_selecto),
[Orders](http://localhost:4199/orders_selecto),
[Employees](http://localhost:4199/employees_selecto), or
[Selecto dashboard](http://localhost:4199/dev/dashboard/selecto).
The isolated databases are `selecto_northwind_tutorial_20260909_dev` and
`selecto_northwind_tutorial_20260909_test`.

- Product popup customization: `lib/selecto_northwind/selecto_domains/overlays/product_domain_overlay.ex`.
- Filter-set persistence: `lib/selecto_northwind/filter_sets.ex`.
- Column presets: `lib/selecto_northwind/saved_view_config_context.ex`.
- Product LiveView passes filter-set and preset assigns into the Form component explicitly.
- Parameterized customer join: `lib/selecto_northwind/selecto_domains/order_domain.ex`.

Verification: `mise exec -- mix precommit` passed 8 tests; assets built; both
parameterized-join validation commands passed. With the server running,
`mise exec -- mix run scripts/verify_tutorial.exs` verifies 17 HTTP routes,
executes tag and parameterized joins against seeded PostgreSQL data, and checks
saved-view, column-preset, and filter-set persistence within a rolled-back transaction.
These checks do not cover browser interactions such as dragging columns or opening the modal.

### Local sibling run

The branch now uses the canonical ecosystem dependency helper. Run with
`SELECTO_ECOSYSTEM_USE_LOCAL=1 PORT=4199 mise exec -- mix phx.server`.
`SELECTO_ECOSYSTEM_USE_LOCAL=0` uses pinned Git dependencies, not the earlier Hex setup.

Verified local checkouts: Selecto `377492d`, Components `12e165d`, PostgreSQL
adapter `a23c3bb`, Mix generators `68d8b52` (all report version 0.5.0).
Local compilation, asset setup/build, precommit (8 tests), and parameterized-join
validation passed. Runtime verification failed: Products and Orders return HTTP
500 because the local relation validator rejects the generated OrderDetail
`primary_key: [:order_id, :product_id]`. Customers, the dashboard, and the checked
Product/Customer contract and guide endpoints returned HTTP 200. The additional
route sweep stopped at an Orders contract transport error; remaining routes and
local-mode database/persistence checks are not verified. The earlier successful
runtime results above apply to the released Hex packages only.

The failure originates in `selecto/lib/selecto/domain/contract/relations.ex`,
which requires a scalar primary key, while the tutorial's generated relation
preserves the Northwind composite key. No sibling repository code was changed.
