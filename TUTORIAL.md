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
- The Northwind database schema and data loaded (see README.md)

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

## Step 2: Generate Customer Management View

*Coming soon - This step will cover using `mix selecto.gen.live` to create a full-featured customer management interface*

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