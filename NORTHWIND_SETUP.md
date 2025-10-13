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

## Special Join Modes for Optimized Queries

This project demonstrates three special join modes (`lookup`, `star`, `tag`) that optimize common relationship patterns in Selecto:

### Lookup Mode (Small Reference Tables)

**Use case**: Small reference tables (< 20 items) like Categories

**Example**: Categories in the Product domain

```elixir
# In lib/selecto_northwind/selecto_domains/product_domain.ex
:category_name => %{
  type: :string,
  display_field: :category_name,
  filter_type: :multi_select_id,
  id_field: :id,
  join_mode: :lookup,
  prevent_denormalization: true,
  group_by_filter: "category_id"  # Filter on products.category_id
}
```

**Benefits**:
- Displays user-friendly checkboxes with category names
- Filters efficiently on `products.category_id` without joining
- Uses SQL `IN` operator: `WHERE category_id = ANY($1)`
- Prevents denormalization of category data

**Generated automatically with**:
```bash
mix selecto.gen.domain SelectoNorthwind.Catalog.Product \
  --expand-lookup Category:category_name
```

### Star Mode (Medium-Sized Lookup Tables)

**Use case**: Larger reference tables (20-100 items) like Suppliers

**Example**: Suppliers in the Product domain

```elixir
# In lib/selecto_northwind/selecto_domains/product_domain.ex
:company_name => %{
  type: :string,
  display_field: :company_name,
  filter_type: :multi_select_id,
  id_field: :id,
  join_mode: :star,
  prevent_denormalization: true,
  group_by_filter: "supplier_id"  # Filter on products.supplier_id
}
```

**Benefits**:
- Displays searchable multi-select dropdown (better UX for more items)
- Filters efficiently on `products.supplier_id` without joining
- Uses SQL `IN` operator: `WHERE supplier_id = ANY($1)`
- Prevents denormalization of supplier data

**Generated automatically with**:
```bash
mix selecto.gen.domain SelectoNorthwind.Catalog.Product \
  --expand-star Supplier:company_name
```

### Tag Mode (Many-to-Many Relationships)

**Use case**: Many-to-many relationships via junction tables

**Example**: Tags associated with Products

```elixir
# In lib/selecto_northwind/selecto_domains/product_domain.ex
:name => %{
  type: :string,
  display_field: :name,
  filter_type: :multi_select_id,
  id_field: :id,
  join_mode: :tag,
  prevent_denormalization: true
}
```

**Benefits**:
- Optimized for many-to-many queries through junction tables
- Displays multi-select UI for tag selection
- Filters using ID-based operations
- Prevents expensive denormalization

**Generated automatically with**:
```bash
mix selecto.gen.domain SelectoNorthwind.Catalog.Product \
  --expand-tag Tags:name
```

### Key Metadata Fields

All three join modes use these metadata fields:

- `join_mode`: `:lookup`, `:star`, or `:tag` - determines query optimization strategy
- `filter_type`: `:multi_select_id` - enables multi-select filter UI
- `display_field`: Field shown to users (e.g., `:category_name`, `:company_name`)
- `id_field`: Field used for filtering (typically `:id`)
- `group_by_filter`: Local foreign key field to filter on (e.g., `"category_id"`)
- `prevent_denormalization`: `true` - prevents denormalizing related data into results

### How It Works

1. **UI Layer**: Renders checkboxes (lookup) or dropdown (star/tag) with human-readable names
2. **Filter Creation**: When filtering, creates filter on local foreign key (e.g., `category_id`)
3. **Query Optimization**: Filters using `WHERE field_id = ANY($1)` - no JOIN needed!
4. **Display**: Shows names to users but filters on IDs internally

### Testing Join Modes

Visit http://localhost:4000/products_selecto and try:

1. **Lookup Mode** - Add "Category ID" filter:
   - Should show ~8 checkboxes with category names
   - Select multiple categories
   - Query filters on `products.category_id` without JOIN

2. **Star Mode** - Add "Supplier ID" filter:
   - Should show searchable dropdown with ~29 supplier names
   - Hold Ctrl/Cmd to select multiple
   - Query filters on `products.supplier_id` without JOIN

3. **Tag Mode** - Add filter for tags (if configured):
   - Shows multi-select for tag names
   - Handles many-to-many efficiently

### Performance Comparison

**Without join modes** (traditional approach):
```sql
SELECT * FROM products
JOIN categories ON products.category_id = categories.id
WHERE categories.category_name IN ('Beverages', 'Condiments');
```

**With lookup mode**:
```sql
SELECT * FROM products
WHERE products.category_id = ANY(ARRAY[1, 2]);
```

The join mode approach is:
- ✅ Simpler SQL
- ✅ Faster execution (no JOIN overhead)
- ✅ Better for indexes
- ✅ Cleaner query plans
```