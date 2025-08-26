# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SelectoNorthwind.Repo.insert!(%SelectoNorthwind.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias SelectoNorthwind.Repo
alias SelectoNorthwind.Catalog.{Category, Supplier, Product}
alias SelectoNorthwind.Sales.{Customer, Order, OrderDetail, Shipper, CustomerDemographic, CustomerCustomerDemo}
alias SelectoNorthwind.Hr.{Employee, EmployeeTerritory}
alias SelectoNorthwind.Geography.{Region, Territory, UsState}

# Clear existing data (for development)
if Mix.env() == :dev do
  Repo.delete_all(OrderDetail)
  Repo.delete_all(Order)
  Repo.delete_all(CustomerCustomerDemo)
  Repo.delete_all(EmployeeTerritory)
  Repo.delete_all(Territory)
  Repo.delete_all(Region)
  Repo.delete_all(Product)
  Repo.delete_all(Category)
  Repo.delete_all(Supplier)
  Repo.delete_all(Customer)
  Repo.delete_all(Employee)
  Repo.delete_all(Shipper)
  Repo.delete_all(CustomerDemographic)
  Repo.delete_all(UsState)
end

# Seed Categories
categories = [
  %{category_name: "Beverages", description: "Soft drinks, coffees, teas, beers, and ales"},
  %{category_name: "Condiments", description: "Sweet and savory sauces, relishes, spreads, and seasonings"},
  %{category_name: "Dairy Products", description: "Cheeses"},
  %{category_name: "Grains/Cereals", description: "Breads, crackers, pasta, and cereal"},
  %{category_name: "Meat/Poultry", description: "Prepared meats"},
  %{category_name: "Produce", description: "Dried fruit and bean curd"},
  %{category_name: "Seafood", description: "Seaweed and fish"},
  %{category_name: "Confections", description: "Desserts, candies, and sweet breads"}
]

Enum.each(categories, fn category ->
  Repo.insert!(Category.changeset(%Category{}, category))
end)

# Seed Suppliers
suppliers = [
  %{
    company_name: "Exotic Liquids",
    contact_name: "Charlotte Cooper",
    contact_title: "Purchasing Manager",
    address: "49 Gilbert St.",
    city: "London",
    postal_code: "EC1 4SD",
    country: "UK",
    phone: "(171) 555-2222"
  },
  %{
    company_name: "New Orleans Cajun Delights",
    contact_name: "Shelley Burke",
    contact_title: "Order Administrator",
    address: "P.O. Box 78934",
    city: "New Orleans",
    region: "LA",
    postal_code: "70117",
    country: "USA",
    phone: "(100) 555-4822"
  },
  %{
    company_name: "Grandma Kelly's Homestead",
    contact_name: "Regina Murphy",
    contact_title: "Sales Representative",
    address: "707 Oxford Rd.",
    city: "Ann Arbor",
    region: "MI",
    postal_code: "48104",
    country: "USA",
    phone: "(313) 555-5735"
  }
]

Enum.each(suppliers, fn supplier ->
  Repo.insert!(Supplier.changeset(%Supplier{}, supplier))
end)

# Seed Shippers
shippers = [
  %{company_name: "Speedy Express", phone: "(503) 555-9831"},
  %{company_name: "United Package", phone: "(503) 555-3199"},
  %{company_name: "Federal Shipping", phone: "(503) 555-9931"}
]

Enum.each(shippers, fn shipper ->
  Repo.insert!(Shipper.changeset(%Shipper{}, shipper))
end)

# Seed Regions
regions = [
  %{region_description: "Eastern"},
  %{region_description: "Western"},
  %{region_description: "Northern"},
  %{region_description: "Southern"}
]

Enum.each(regions, fn region ->
  Repo.insert!(Region.changeset(%Region{}, region))
end)

# Seed some sample customers
customers = [
  %{
    customer_id: "ALFKI",
    company_name: "Alfreds Futterkiste",
    contact_name: "Maria Anders",
    contact_title: "Sales Representative",
    address: "Obere Str. 57",
    city: "Berlin",
    postal_code: "12209",
    country: "Germany",
    phone: "030-0074321"
  },
  %{
    customer_id: "ANATR",
    company_name: "Ana Trujillo Emparedados y helados",
    contact_name: "Ana Trujillo",
    contact_title: "Owner",
    address: "Avda. de la Constitución 2222",
    city: "México D.F.",
    postal_code: "05021",
    country: "Mexico",
    phone: "(5) 555-4729"
  }
]

Enum.each(customers, fn customer ->
  Repo.insert!(Customer.changeset(%Customer{}, customer))
end)

# Seed employees
employees = [
  %{
    last_name: "Davolio",
    first_name: "Nancy",
    title: "Sales Representative",
    title_of_courtesy: "Ms.",
    birth_date: ~D[1948-12-08],
    hire_date: ~D[1992-05-01],
    address: "507 - 20th Ave. E.\nApt. 2A",
    city: "Seattle",
    region: "WA",
    postal_code: "98122",
    country: "USA",
    home_phone: "(206) 555-9857",
    extension: "5467"
  },
  %{
    last_name: "Fuller",
    first_name: "Andrew",
    title: "Vice President, Sales",
    title_of_courtesy: "Dr.",
    birth_date: ~D[1952-02-19],
    hire_date: ~D[1992-08-14],
    address: "908 W. Capital Way",
    city: "Tacoma",
    region: "WA",
    postal_code: "98401",
    country: "USA",
    home_phone: "(206) 555-9482",
    extension: "3457"
  }
]

Enum.each(employees, fn employee ->
  Repo.insert!(Employee.changeset(%Employee{}, employee))
end)

# Get IDs for relationships
categories_by_name = Repo.all(Category) |> Enum.into(%{}, fn cat -> {cat.category_name, cat} end)
suppliers_by_name = Repo.all(Supplier) |> Enum.into(%{}, fn sup -> {sup.company_name, sup} end)

# Seed some products
products = [
  %{
    product_name: "Chai",
    supplier_id: suppliers_by_name["Exotic Liquids"].id,
    category_id: categories_by_name["Beverages"].id,
    quantity_per_unit: "10 boxes x 20 bags",
    unit_price: Decimal.new("18.00"),
    units_in_stock: 39,
    units_on_order: 0,
    reorder_level: 10,
    discontinued: false
  },
  %{
    product_name: "Chang",
    supplier_id: suppliers_by_name["Exotic Liquids"].id,
    category_id: categories_by_name["Beverages"].id,
    quantity_per_unit: "24 - 12 oz bottles",
    unit_price: Decimal.new("19.00"),
    units_in_stock: 17,
    units_on_order: 40,
    reorder_level: 25,
    discontinued: false
  },
  %{
    product_name: "Chef Anton's Cajun Seasoning",
    supplier_id: suppliers_by_name["New Orleans Cajun Delights"].id,
    category_id: categories_by_name["Condiments"].id,
    quantity_per_unit: "48 - 6 oz jars",
    unit_price: Decimal.new("22.00"),
    units_in_stock: 53,
    units_on_order: 0,
    reorder_level: 0,
    discontinued: false
  }
]

Enum.each(products, fn product ->
  Repo.insert!(Product.changeset(%Product{}, product))
end)

IO.puts("✅ Database seeded successfully!")
IO.puts("📊 Seeded #{length(categories)} categories")
IO.puts("🏪 Seeded #{length(suppliers)} suppliers")
IO.puts("🚚 Seeded #{length(shippers)} shippers")
IO.puts("🌍 Seeded #{length(regions)} regions")
IO.puts("👥 Seeded #{length(customers)} customers")
IO.puts("👩‍💼 Seeded #{length(employees)} employees")
IO.puts("📦 Seeded #{length(products)} products")
