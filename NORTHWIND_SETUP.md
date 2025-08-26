# Northwind Database Setup

This project includes a complete implementation of the classic Northwind sample database using Elixir, Phoenix, and Ecto.

## Database Structure

### Tables Created (14 total)
- **Categories** - Product categories
- **Suppliers** - Product suppliers
- **Products** - Product catalog with foreign keys to categories and suppliers
- **Customers** - Customer information
- **Employees** - Employee records with self-referencing relationships
- **Shippers** - Shipping companies
- **Orders** - Order headers linked to customers and employees
- **Order Details** - Line items for orders (products, quantities, prices)
- **Regions** - Geographic regions
- **Territories** - Sales territories linked to regions
- **Employee Territories** - Many-to-many junction table
- **Customer Demographics** - Customer demographic categories
- **Customer Customer Demo** - Many-to-many junction for customer demographics
- **US States** - US state reference data

### Schema Organization

The schemas are organized into domain contexts:

- **Catalog Context** (`SelectoNorthwind.Catalog`)
  - `Category`
  - `Supplier` 
  - `Product`

- **Sales Context** (`SelectoNorthwind.Sales`)
  - `Customer`
  - `Order`
  - `OrderDetail`
  - `Shipper`
  - `CustomerDemographic`
  - `CustomerCustomerDemo`

- **HR Context** (`SelectoNorthwind.Hr`)
  - `Employee`
  - `EmployeeTerritory`

- **Geography Context** (`SelectoNorthwind.Geography`)
  - `Region`
  - `Territory`
  - `UsState`

## Running the Setup

1. **Run migrations** to create the database structure:
   ```bash
   mix ecto.migrate
   ```

2. **Seed the database** with sample data:
   ```bash
   mix run priv/repo/seeds.exs
   ```

## Example Queries

### Basic Queries

```elixir
alias SelectoNorthwind.{Repo, Catalog, Sales}

# Get all products
products = Repo.all(Catalog.Product)

# Get all categories
categories = Repo.all(Catalog.Category)

# Get all orders
orders = Repo.all(Sales.Order)
```

### Queries with Associations

```elixir
import Ecto.Query

# Products with their categories and suppliers
query = from p in Catalog.Product,
  join: c in assoc(p, :category),
  join: s in assoc(p, :supplier),
  select: {p.product_name, c.category_name, s.company_name}

results = Repo.all(query)
```

### Preloaded Associations

```elixir
# Load products with their associated category and supplier
products = Repo.all(Catalog.Product) |> Repo.preload([:category, :supplier])

# Access associations
Enum.each(products, fn product ->
  IO.puts("#{product.product_name} - #{product.category.category_name}")
end)
```

### Complex Queries

```elixir
# Find all orders for a specific customer with order details
customer_orders = 
  from o in Sales.Order,
  where: o.customer_id == "ALFKI",
  preload: [order_details: :product]

orders = Repo.all(customer_orders)
```

## Key Features

- ✅ Complete Northwind database schema
- ✅ Proper foreign key relationships and constraints
- ✅ Many-to-many associations (employees↔territories, customers↔demographics)
- ✅ Self-referential relationships (employee reports_to)
- ✅ Mixed primary key types (integer auto-increment and string keys)
- ✅ Comprehensive seed data
- ✅ Organized into domain contexts
- ✅ Full Ecto association support

## Sample Data Included

The seed file includes:
- 8 product categories
- 3 suppliers
- 3 shipping companies
- 4 geographic regions
- 2 sample customers
- 2 sample employees
- 3 sample products

You can extend the seed data by adding more entries to `priv/repo/seeds.exs`.

## Testing

To verify everything is working:

```bash
# Test basic product query
mix run -e 'alias SelectoNorthwind.{Repo, Catalog}; Repo.all(Catalog.Product) |> length() |> IO.puts()'

# Test associations
mix run -e 'alias SelectoNorthwind.{Repo, Catalog}; import Ecto.Query; from(p in Catalog.Product, join: c in assoc(p, :category), select: {p.product_name, c.category_name}) |> Repo.all() |> IO.inspect()'
```