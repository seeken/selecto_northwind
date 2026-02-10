# SelectoNorthwind

A sample Phoenix application demonstrating the **Selecto ecosystem** -- a suite of Elixir libraries for building interactive data exploration interfaces in Phoenix LiveView. It uses the classic Northwind sample database as a realistic, multi-context dataset.

This project also serves as the primary development sandbox for [selecto_mix](https://github.com/yourorg/selecto_mix), with the ability to make complementary changes to [selecto](https://github.com/yourorg/selecto) and [selecto_components](https://github.com/yourorg/selecto_components) as needed.

## The Selecto Ecosystem

**Selecto** lets you point a code generator at your Ecto schemas (or a raw Postgrex connection) and get a working, interactive data explorer out of the box -- with filtering, sorting, aggregation, charts, and saved views -- then customize from there.

The ecosystem has three packages:

| Package | Purpose |
|---------|---------|
| **selecto** | Core query builder. Constructs complex, fully-parameterized SQL from a domain configuration. Handles dynamic filters, joins (including star schemas, hierarchies, many-to-many), CTEs, window functions, and more. |
| **selecto_mix** | Mix tasks that introspect your Ecto schemas and generate complete Selecto domain configs, query helpers, and optionally full LiveView pages. Regeneration preserves your customizations. |
| **selecto_components** | Phoenix LiveView components: drag-and-drop query builder, sortable paginated tables, aggregate views, Chart.js graphs, and saved views. Pre-styled with Tailwind CSS. |

### Typical workflow

```bash
# 1. Generate a domain from an Ecto schema
mix selecto.gen.domain MyApp.Catalog.Product --expand-schemas category,supplier --live --saved-views

# 2. Add the generated route to your router
live "/product", MyAppWeb.ProductLive, :index

# 3. Run migrations and start the server
mix ecto.migrate
mix phx.server
```

You get an interactive data explorer with filtering, sorting, multiple view types, and saved queries -- no hand-written SQL required.

## The Northwind Database

The classic Northwind dataset is organized into domain contexts that exercise different schema patterns:

- **Catalog** -- Products, Categories, Suppliers, Tags (many-to-many, JSONB attributes)
- **Sales** -- Customers, Orders, OrderDetails, Shippers (complex order hierarchies)
- **HR** -- Employees, EmployeeTerritories (self-referential manager/subordinate relationships)
- **Geography** -- Regions, Territories, US States (hierarchical locations)

This gives Selecto a realistic workout across joins, aggregations, and relationship patterns.

## Getting Started

### Prerequisites

- Elixir ~> 1.15
- PostgreSQL 12+
- Node.js (for asset building)

### Setup

```bash
# Clone with submodules
git clone --recurse-submodules <repo-url>
cd selecto_northwind

# Or if already cloned:
git submodule update --init --recursive

# Install dependencies, create database, seed data, build assets
mix setup

# Start the server
mix phx.server
```

Visit [localhost:4000](http://localhost:4000) to see the app. The built-in tutorial at [localhost:4000/tutorial](http://localhost:4000/tutorial) walks through generating Selecto domains for each Northwind context step by step.

There is also a [Postgrex tutorial](http://localhost:4000/postgrex_tutorial) demonstrating how to use Selecto without Ecto, connecting directly to a database.

## Development

### Common commands

```bash
mix phx.server                  # Start the server
iex -S mix phx.server           # Start with IEx shell
mix test                        # Run tests
mix precommit                   # Compile (warnings-as-errors), format, test
mix ecto.reset                  # Drop and recreate database with seed data
```

### Submodule management

The three Selecto packages live in `vendor/` as git submodules:

```bash
git submodule update --remote                      # Update all to latest
git submodule update --remote vendor/selecto_mix   # Update one
git submodule foreach git pull origin main          # Pull latest for all
```

## Contributing

Contributions to any part of the Selecto ecosystem are welcome. Areas where help is especially appreciated:

- Trying Selecto against your own schemas and reporting rough edges
- UI/UX feedback on the LiveView components
- Additional view types and visualizations
- Documentation and examples
- Testing across different Postgres versions and schema patterns
- Accessibility improvements in the component library

See the individual package repos for contribution guidelines, or open an issue here to discuss.
