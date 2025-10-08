# Devcontainer Configuration

This project uses the standard Elixir devcontainer setup with the following configuration:

## Structure

- **devcontainer.json**: Main configuration file that defines the devcontainer setup
- **docker-compose.yml**: Defines the services (app and db) and their configuration
- **Dockerfile**: Custom image based on `elixir:1.16.2-slim` with necessary tools

## Features

- **Elixir 1.16.2** with Erlang 26
- **PostgreSQL 16** database service
- **Node.js 18** for Phoenix assets
- **Auto-installed VS Code extensions**:
  - ElixirLS (language server)
  - Credo (linting)
  - Jinja HTML (template support)

## Setup

The devcontainer will automatically:
1. Install Hex and Rebar
2. Install dependencies with `mix deps.get`
3. Set up the database with `mix ecto.setup`

## Usage

After the devcontainer builds and starts:

- Phoenix server: `mix phx.server` (accessible at http://localhost:4000)
- Run tests: `mix test`
- Database console: `psql -h localhost -U postgres selecto_northwind_dev`

## Services

- **app**: Main Elixir/Phoenix application container
- **db**: PostgreSQL 16 database container

The app service uses `network_mode: service:db` so both services share the same network namespace, making the database accessible at `localhost:5432`.
