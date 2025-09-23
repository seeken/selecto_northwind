# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SelectoNorthwind is a Phoenix 1.8 web application that serves as a **development sandbox specifically for selecto_mix**. The primary purpose is to develop, test, and iterate on selecto_mix functionality using the classic Northwind sample database as a realistic dataset. This project also facilitates making complementary changes to selecto and selecto_components when needed to support selecto_mix development.

It's built with Elixir/Phoenix and uses PostgreSQL with Ecto for data persistence.

## Development Commands

### Initial Setup
```bash
git submodule update --init --recursive  # Initialize vendor submodules
mix setup                               # Install dependencies, setup database, build assets
```

### Daily Development
```bash
mix phx.server                         # Start Phoenix server (localhost:4000)
iex -S mix phx.server                 # Start server with interactive Elixir shell
```

### Database Operations
```bash
mix ecto.migrate                      # Run database migrations
mix run priv/repo/seeds.exs          # Seed database with sample data
mix ecto.setup                       # Create database, migrate, and seed
mix ecto.reset                       # Drop and recreate database
```

### Testing and Quality
```bash
mix test                             # Run all tests
mix test test/path/to/test.exs       # Run specific test file
mix test --failed                    # Re-run only failed tests
mix precommit                        # Run full precommit checks (compile, format, test)
```

### Asset Management
```bash
mix assets.build                     # Build CSS and JS assets
mix assets.deploy                    # Build and minify assets for production
```

### Submodule Management
The project uses git submodules for vendor dependencies, with **selecto_mix being the primary focus**:
- `vendor/selecto_mix` - **Main development target**: Mix tasks and generators
- `vendor/selecto` - Core Selecto library (modified as needed to support selecto_mix)
- `vendor/selecto_components` - Phoenix LiveView components (modified as needed to support selecto_mix)

```bash
git submodule update --remote         # Update all submodules to latest
git submodule update --remote vendor/selecto_mix  # Update selecto_mix specifically
git submodule update --remote vendor/selecto      # Update core library
git submodule foreach git pull origin main        # Pull latest for all submodules
```

## Architecture

### Database Schema Organization
The Northwind database is organized into domain contexts:

- **Catalog Context** (`SelectoNorthwind.Catalog`): Categories, Products, Suppliers
- **Sales Context** (`SelectoNorthwind.Sales`): Customers, Orders, OrderDetails, Shippers, Customer Demographics
- **HR Context** (`SelectoNorthwind.Hr`): Employees, Employee Territories
- **Geography Context** (`SelectoNorthwind.Geography`): Regions, Territories, US States

### Application Structure
- **Web Layer** (`SelectoNorthwindWeb`): Controllers, LiveViews, Components, Router
- **Business Logic** (`SelectoNorthwind`): Domain contexts, schemas, business logic
- **Data Layer** (`SelectoNorthwind.Repo`): Ecto repository for database operations

### Key Files
- `lib/selecto_northwind_web/router.ex`: Route definitions
- `lib/selecto_northwind/application.ex`: OTP application supervision tree
- `priv/repo/migrations/`: Database migration files
- `priv/repo/seeds.exs`: Database seeding script

### Dependencies
- Phoenix 1.8 web framework
- Ecto/PostgreSQL for database
- LiveView for real-time UI
- Tailwind CSS for styling
- **selecto_mix** (primary development focus) - Mix tasks and generators
- selecto - Core Selecto library 
- selecto_components - Phoenix LiveView components

## Development Guidelines

### selecto_mix Development
This sandbox is specifically designed for developing and testing selecto_mix:
- Use the Northwind database as a realistic dataset for testing Mix tasks and generators
- Make changes to selecto and selecto_components as needed to support selecto_mix functionality
- Test selecto_mix features against the full Northwind schema with relationships and realistic data
- Leverage the domain contexts (Catalog, Sales, HR, Geography) to test different use cases

### Phoenix/LiveView Patterns
- Always use `<.link navigate={href}>` and `<.link patch={href}>` instead of deprecated live_redirect/live_patch
- Use `to_form/2` for form handling, never access changesets directly in templates
- Wrap LiveView templates with `<Layouts.app flash={@flash} ...>`
- Use LiveView streams for collections to avoid memory issues

### HTTP Requests  
Use the included `:req` library for HTTP requests. Avoid `:httpoison`, `:tesla`, or `:httpc`.

### Code Quality
Run `mix precommit` before committing changes - this runs compile checks, formatting, and tests.

### Testing
- Test files are in `test/` directory following Phoenix conventions
- Use `Phoenix.LiveViewTest` for LiveView testing
- Use `LazyHTML` for HTML assertions in tests
- Always add unique DOM IDs to elements for testing

## Database Queries

### Basic Pattern
```elixir
alias SelectoNorthwind.{Repo, Catalog, Sales}
import Ecto.Query

# Simple queries
products = Repo.all(Catalog.Product)
categories = Repo.all(Catalog.Category)

# With preloaded associations  
products = Repo.all(Catalog.Product) |> Repo.preload([:category, :supplier])

# Complex queries with joins
query = from p in Catalog.Product,
  join: c in assoc(p, :category),
  select: {p.product_name, c.category_name}
```
- never put reference to the main project in any of the vendored projects
- when you are obsoleting code, delete it!