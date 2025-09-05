# SelectoNorthwind

A development sandbox specifically for **selecto_mix**, using the Northwind database as a realistic testing environment. This project serves as the primary development and testing ground for selecto_mix functionality, with the ability to make complementary changes to selecto and selecto_components as needed.

## Setup

This project uses git submodules for vendor dependencies. After cloning:

1. **Initialize submodules:**
   ```bash
   git submodule update --init --recursive
   ```

2. **Install and setup dependencies:**
   ```bash
   mix setup
   ```

3. **Start Phoenix endpoint:**
   ```bash
   mix phx.server
   # or inside IEx with:
   iex -S mix phx.server
   ```

## Submodule Management

This project includes three vendor dependencies as git submodules, with **selecto_mix being the primary focus**:
- `vendor/selecto_mix` - **Main development target**: Mix tasks and generators
- `vendor/selecto` - Core Selecto library (modified as needed to support selecto_mix)
- `vendor/selecto_components` - Phoenix LiveView components (modified as needed to support selecto_mix)

**Update all submodules to latest:**
```bash
git submodule update --remote
```

**Update specific submodule (especially selecto_mix):**
```bash
git submodule update --remote vendor/selecto_mix
git submodule update --remote vendor/selecto
```

**Pull latest changes for all submodules:**
```bash
git submodule foreach git pull origin main
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Selecto Integration

After running `mix selecto.gen.domain SelectoNorthwind.Catalog.Product --expand-schemas category,supplier --live --saved-views`, you'll see output with next steps like:

### Add Route to Router

Add this route to your `router.ex`:
```elixir
live "/product", SelectoNorthwindWeb.ProductLive, :index
```

### Next Steps

1. **Run database migrations:**
   ```bash
   mix ecto.migrate
   ```

2. **Add SavedViewContext to domain modules:**
   ```elixir
   use SelectoNorthwind.SavedViewContext
   ```

3. **Set saved_view_context assign in LiveViews:**
   Configure the `saved_view_context` assign in your LiveView modules to enable saved view functionality.

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
