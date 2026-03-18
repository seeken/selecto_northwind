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

`mix setup` installs dependencies, creates the database, runs migrations, seeds Northwind data, and builds assets.

## What You Get

The tutorial walks through generating Selecto domains and LiveViews over a realistic sample dataset, including:

- catalog data such as products, suppliers, categories, and tags
- sales data such as customers, orders, and shippers
- HR and geography relationships for more complex join patterns

## Useful Commands

```bash
mix phx.server
iex -S mix phx.server
mix test
mix precommit
mix ecto.reset
```
