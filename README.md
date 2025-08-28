# SelectoNorthwind

A development sandbox for testing Selecto libraries with the Northwind database.

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

This project includes three vendor dependencies as git submodules:
- `vendor/selecto` - Core Selecto library
- `vendor/selecto_components` - Phoenix LiveView components
- `vendor/selecto_mix` - Mix tasks and generators

**Update all submodules to latest:**
```bash
git submodule update --remote
```

**Update specific submodule:**
```bash
git submodule update --remote vendor/selecto
```

**Pull latest changes for all submodules:**
```bash
git submodule foreach git pull origin main
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
