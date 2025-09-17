# Selecto Integration Tutorial

Welcome to the Selecto Northwind integration tutorial! This guide will walk you through integrating Selecto and its related libraries into a Phoenix application using the classic Northwind database as our example dataset.

## Tutorial Structure

This tutorial is organized into steps, with each step building upon the previous one. You can:
- Follow along from the beginning by checking out the `main` branch
- Jump to any step by checking out `tutorial-step-N` (where N is the step number)
- Compare your work with the reference implementation by diffing against the step branches

## Prerequisites

Before starting, ensure you have:
- Elixir 1.14+ installed
- Phoenix 1.8+ framework knowledge
- PostgreSQL database running

## Step 0: Set Up the Basic Phoenix Project

Before integrating Selecto, you need to set up the basic Phoenix application with the Northwind database. This step ensures you have a working Phoenix app with the database schema and sample data loaded.

### Clone the Repository

```bash
git clone <repository-url>
cd selecto_northwind
```

### Initialize Git Submodules

The project includes Selecto libraries as git submodules in the vendor directory:

```bash
git submodule update --init --recursive
```

### Install Dependencies

Install all Phoenix and Elixir dependencies:

```bash
mix setup
```

This command runs:
- `mix deps.get` - Fetches all dependencies
- `mix ecto.create` - Creates the database
- `mix ecto.migrate` - Runs database migrations
- `mix run priv/repo/seeds.exs` - Seeds the Northwind sample data
- `npm install` - Installs JavaScript dependencies

### Alternative: Manual Setup

If you prefer to run the commands individually:

```bash
# Install Elixir dependencies
mix deps.get

# Create the database
mix ecto.create

# Run migrations to create the Northwind schema
mix ecto.migrate

# Seed the database with Northwind sample data
mix run priv/repo/seeds.exs

# Install Node.js dependencies
cd assets && npm install && cd ..

# Build assets
mix assets.build
```

### Verify the Setup

Start the Phoenix server to ensure everything is working:

```bash
mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000) and you should see the Northwind Demo landing page with navigation links to Customers, Catalog, Orders, and Analytics sections.

### Check Database Connection

Verify the database is properly seeded with data:

```bash
iex -S mix

# In the IEx console:
alias SelectoNorthwind.Repo
import Ecto.Query

# Check for data in the tables
Repo.aggregate(from(p in "products"), :count)
# Should return 77 (or similar number of products)

Repo.aggregate(from(c in "customers"), :count)
# Should return 91 (or similar number of customers)
```

### Development Commands Reference

Common commands you'll use during development:

```bash
# Start Phoenix server
mix phx.server

# Start server with interactive Elixir shell
iex -S mix phx.server

# Run tests
mix test

# Run precommit checks
mix precommit

# Reset database (drop, create, migrate, seed)
mix ecto.reset
```

### Next Step

With the basic Phoenix application set up and the Northwind database loaded, you're ready to proceed to Step 1 where we'll add the Selecto dependencies.

## Step 1: Add Selecto Dependencies

The first step is to add the Selecto libraries to your Phoenix project. These libraries provide powerful data selection, filtering, and UI components for your application.

### Add Dependencies to mix.exs

Open your `mix.exs` file and add the following dependencies to the `deps` function:

```elixir
defp deps do
  [
    # ... existing dependencies ...

    # Selecto libraries
    {:selecto, path: "./vendor/selecto"},
    {:selecto_components, path: "./vendor/selecto_components"},
    {:selecto_mix, path: "./vendor/selecto_mix", only: [:dev, :test]}
  ]
end
```

**Note:** These dependencies are referenced as local paths because they are included as git submodules in the vendor directory. In a production environment, you would typically reference them from Hex or GitHub.

### What Each Library Does

- **`selecto`**: Core library providing the query builder and data selection engine
- **`selecto_components`**: Pre-built Phoenix LiveView components for data tables, filters, and visualizations
- **`selecto_mix`**: Mix tasks and generators for scaffolding Selecto-based views and components (development only)

### Initialize Git Submodules

If you haven't already, initialize the vendor submodules:

```bash
git submodule update --init --recursive
```

### Install Dependencies

After adding the dependencies, fetch and compile them:

```bash
mix deps.get
mix deps.compile
```

### Verify Installation

You can verify that the Selecto libraries are properly installed by running:

```bash
mix help | grep selecto
```

You should see several new Mix tasks available, including:
- `mix selecto.gen.live` - Generate a LiveView with Selecto components
- `mix selecto.gen.domain` - Generate a domain configuration
- `mix selecto.gen.dashboard` - Generate a dashboard view

### Next Step

With the dependencies installed, you're ready to move on to Step 2, where we'll generate our first Selecto-powered view for the Customers table.

---

## Step 2: Generate Products Domain with Selecto

In this step, we'll use the `mix selecto.gen.domain` task to generate Selecto domain configuration for the Product schema and its related schemas (Categories and Suppliers) from the Catalog context.

### Understanding Selecto Domains

Selecto domains provide a configuration layer on top of your existing Ecto schemas. They define how tables relate to each other, what fields to display, and how to query the data efficiently.

### Generate the Products Domain

Run the following Mix task:

```bash
mix selecto.gen.domain SelectoNorthwind.Catalog.Product --expand-schemas SelectoNorthwind.Catalog.Category SelectoNorthwind.Catalog.Supplier --live --saved-views
```

When prompted about uncommitted changes and SelectoComponents integration, answer "Y" to proceed.

This command will:
1. **Analyze your existing Ecto schema** for Product and the expanded schemas (Category, Supplier)
2. **Generate a Selecto domain configuration** that maps these schemas and their relationships
3. **Create LiveView modules** for interactive data exploration (with `--live`)
4. **Generate saved views infrastructure** for persisting user-defined views (with `--saved-views`)
5. **Integrate SelectoComponents assets** (Chart.js, Alpine.js, hooks, and styles)

### What Gets Generated

The task creates several files:

#### Selecto Domain Configuration
```
lib/selecto_northwind/selecto_domains/
  └── products_domain.ex  # Domain configuration with Product and related schemas
```

This file contains configurations for the Product schema and expanded schemas (Category, Supplier) defining:
- Column definitions with types and labels
- Association mappings
- Default display settings
- Query configurations

#### LiveView Files (with --live flag)
```
lib/selecto_northwind_web/live/
  ├── products_live.ex        # Main LiveView module
  └── products_live.html.heex  # LiveView template
```

The LiveView module includes:
- Selecto query builder integration
- Multiple view types (Table, Detail, Graph)
- Saved view support
- Interactive filtering and sorting

#### Saved Views Infrastructure (with --saved-views flag)
```
lib/selecto_northwind/
  ├── saved_view.ex           # Ecto schema for saved views
  └── saved_view_context.ex   # Context module for saved view operations

priv/repo/migrations/
  └── [timestamp]_create_saved_views.exs  # Database migration
```

#### Asset Integration
The command also updates:
- `assets/js/app.js` - Adds SelectoComponents hooks
- `assets/css/app.css` - Adds SelectoComponents styles source path
- `assets/package.json` - Ensures Chart.js and Alpine.js are configured

### Add SavedView Support to Domain

The generated domain module needs to use the SavedViewContext. Add this line to `lib/selecto_northwind/selecto_domains/products_domain.ex`:

```elixir
defmodule SelectoNorthwind.SelectoDomains.ProductsDomain do
  use SelectoNorthwind.SavedViewContext  # Add this line

  # ... rest of the domain configuration
end
```

This enables the domain to save and load user-defined views.

### Run the Migration

After generation, run the migration to create the saved_views table:

```bash
mix ecto.migrate
```

### Add Route to Router

Add the generated LiveView route to your `lib/selecto_northwind_web/router.ex`:

```elixir
scope "/", SelectoNorthwindWeb do
  pipe_through :browser

  # Add this line for the Products domain
  live "/products", ProductsLive, :index
end
```

### Build Assets

Compile the updated assets with the new SelectoComponents integration:

```bash
mix assets.build
```

### Verify the Setup

Start your Phoenix server and navigate to `/products`:

```bash
mix phx.server
```

You should see the Products Explorer interface with:
- A query builder form
- Data results in table format
- Options to switch between Table, Detail, and Graph views
- Ability to save and load custom views

### Verify the Domain Setup

You can verify the domain is properly set up by running:

```bash
iex -S mix

# In the IEx console:
alias SelectoNorthwind.Catalog
Catalog.list_products()
Catalog.list_categories()
Catalog.list_suppliers()
```

### Seed Sample Data (Optional)

If you want to populate the tables with sample Northwind data:

```bash
mix run priv/repo/seeds/catalog_seeds.exs
```

### Configure Selecto for the Domain

The generated domain configuration (`products_domain.ex`) sets up:
- Table relationships and foreign keys
- Default display fields
- Search and filter configurations
- Join paths between related tables

You can customize this configuration to:
- Add computed fields
- Define custom filters
- Set up aggregations
- Configure display preferences

### Next Step

With the Product domain generated and migrated, you're ready to create LiveView interfaces that leverage these domain models. In Step 3, we'll generate a full-featured Product Catalog interface with filtering and search capabilities.

## Step 3: Add Product Catalog with Filtering

*Coming soon - This step will demonstrate advanced filtering and search capabilities*

## Step 4: Create Order Dashboard

*Coming soon - This step will show how to build analytics dashboards with Selecto components*

## Step 5: Implement Cross-Domain Relationships

*Coming soon - This step will explore joining data across different domain contexts*

## Step 6: Custom Components and Styling

*Coming soon - This step will cover customizing Selecto components to match your design system*

## Troubleshooting

### Common Issues

1. **Compilation errors**: Ensure all submodules are properly initialized
2. **Missing Mix tasks**: Verify that `selecto_mix` is in your dependencies
3. **Database connection issues**: Check your `config/dev.exs` database configuration

### Getting Help

- Check the [Selecto documentation](https://github.com/your-org/selecto)
- Review the example implementations in this repository
- Open an issue if you encounter any problems

## Contributing

If you find any issues with this tutorial or have suggestions for improvement, please open an issue or submit a pull request.