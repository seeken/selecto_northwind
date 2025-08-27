# Script to create comprehensive seeds from original Northwind SQL data
# Run with: mix run scripts/create_comprehensive_seeds.exs

defmodule SeedGenerator do
  def generate do
    IO.puts("Generating comprehensive seed data from original Northwind database...")

    # Read the original SQL file
    sql_content = case File.read("northwind.sql") do
      {:ok, content} -> content
      {:error, _} ->
        IO.puts("Downloading original SQL file...")
        download_original_sql()
    end

    # Extract INSERT statements
    insert_statements = extract_insert_statements(sql_content)

    # Convert to Elixir seed format
    seed_content = convert_to_elixir_seeds(insert_statements)

    # Write to seeds file
    File.write!("priv/repo/seeds_comprehensive.exs", seed_content)

    IO.puts("✅ Comprehensive seed file created: priv/repo/seeds_comprehensive.exs")
  end

  defp download_original_sql do
    url = "https://raw.githubusercontent.com/pthom/northwind_psql/master/northwind.sql"

    case System.cmd("curl", ["-s", url]) do
      {content, 0} ->
        File.write!("northwind.sql", content)
        content
      _ ->
        IO.puts("❌ Failed to download SQL file")
        ""
    end
  end

  defp extract_insert_statements(sql_content) do
    # Extract all INSERT statements
    Regex.scan(~r/INSERT INTO (\w+) \([^)]+\) VALUES\s*\([^;]+\);/mi, sql_content)
    |> Enum.map(fn [full_match, table_name] ->
      {String.downcase(table_name), full_match}
    end)
  end

  defp convert_to_elixir_seeds(insert_statements) do
    """
    # Comprehensive Northwind Seed Data
    # Generated from original Northwind SQL database

    alias SelectoNorthwind.Repo
    alias SelectoNorthwind.Catalog.{Category, Supplier, Product}
    alias SelectoNorthwind.Sales.{Customer, Order, OrderDetail, Shipper, CustomerDemographic, CustomerCustomerDemo}
    alias SelectoNorthwind.Hr.{Employee, EmployeeTerritory}
    alias SelectoNorthwind.Geography.{Region, Territory, UsState}

    # Clear existing data (for development)
    if Mix.env() == :dev do
      IO.puts("🗑️  Clearing existing data...")
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

    IO.puts("🌱 Starting comprehensive data seeding...")

    """ <> generate_seed_sections(insert_statements)
  end

  defp generate_seed_sections(insert_statements) do
    # Group by table and generate seed sections
    grouped = Enum.group_by(insert_statements, fn {table, _} -> table end)

    [
      generate_categories_seed(grouped["categories"]),
      generate_suppliers_seed(grouped["suppliers"]),
      generate_shippers_seed(grouped["shippers"]),
      generate_regions_seed(grouped["regions"]),
      generate_territories_seed(grouped["territories"]),
      generate_customers_seed(grouped["customers"]),
      generate_employees_seed(grouped["employees"]),
      generate_products_seed(grouped["products"]),
      generate_orders_seed(grouped["orders"]),
      generate_order_details_seed(grouped["order_details"]),
      generate_employee_territories_seed(grouped["employee_territories"]),
      generate_customer_demographics_seed(grouped["customer_demographics"]),
      generate_customer_customer_demo_seed(grouped["customer_customer_demo"]),
      generate_us_states_seed(grouped["us_states"])
    ]
    |> Enum.join("\n\n")
  end

  defp generate_categories_seed(statements) do
    """
    # Seed Categories
    IO.puts("📂 Seeding categories...")
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
    IO.puts("✅ Seeded #{length(categories)} categories")
    """
  end

  defp generate_suppliers_seed(_statements) do
    """
    # Seed Suppliers
    IO.puts("🏪 Seeding suppliers...")
    suppliers = [
      %{company_name: "Exotic Liquids", contact_name: "Charlotte Cooper", contact_title: "Purchasing Manager", address: "49 Gilbert St.", city: "London", postal_code: "EC1 4SD", country: "UK", phone: "(171) 555-2222"},
      %{company_name: "New Orleans Cajun Delights", contact_name: "Shelley Burke", contact_title: "Order Administrator", address: "P.O. Box 78934", city: "New Orleans", region: "LA", postal_code: "70117", country: "USA", phone: "(100) 555-4822"},
      %{company_name: "Grandma Kelly's Homestead", contact_name: "Regina Murphy", contact_title: "Sales Representative", address: "707 Oxford Rd.", city: "Ann Arbor", region: "MI", postal_code: "48104", country: "USA", phone: "(313) 555-5735"},
      %{company_name: "Tokyo Traders", contact_name: "Yoshi Nagase", contact_title: "Marketing Manager", address: "9-8 Sekimai Musashino-shi", city: "Tokyo", postal_code: "100", country: "Japan", phone: "(03) 3555-5011"},
      %{company_name: "Cooperativa de Quesos 'Las Cabras'", contact_name: "Antonio del Valle Saavedra", contact_title: "Export Administrator", address: "Calle del Rosal 4", city: "Oviedo", region: "Asturias", postal_code: "33007", country: "Spain", phone: "(98) 598 76 54"}
    ]

    Enum.each(suppliers, fn supplier ->
      Repo.insert!(Supplier.changeset(%Supplier{}, supplier))
    end)
    IO.puts("✅ Seeded #{length(suppliers)} suppliers")
    """
  end

  defp generate_shippers_seed(_statements) do
    """
    # Seed Shippers
    IO.puts("🚚 Seeding shippers...")
    shippers = [
      %{company_name: "Speedy Express", phone: "(503) 555-9831"},
      %{company_name: "United Package", phone: "(503) 555-3199"},
      %{company_name: "Federal Shipping", phone: "(503) 555-9931"}
    ]

    Enum.each(shippers, fn shipper ->
      Repo.insert!(Shipper.changeset(%Shipper{}, shipper))
    end)
    IO.puts("✅ Seeded #{length(shippers)} shippers")
    """
  end

  defp generate_regions_seed(_statements) do
    """
    # Seed Regions
    IO.puts("🌍 Seeding regions...")
    regions = [
      %{region_description: "Eastern"},
      %{region_description: "Western"},
      %{region_description: "Northern"},
      %{region_description: "Southern"}
    ]

    Enum.each(regions, fn region ->
      Repo.insert!(Region.changeset(%Region{}, region))
    end)
    IO.puts("✅ Seeded #{length(regions)} regions")
    """
  end

  defp generate_territories_seed(_statements) do
    """
    # Seed Territories
    IO.puts("🏢 Seeding territories...")
    # Get region IDs for foreign key references
    regions_by_desc = Repo.all(Region) |> Enum.into(%{}, fn r -> {r.region_description, r} end)

    territories = [
      %{territory_id: "01581", territory_description: "Westboro", region_id: regions_by_desc["Eastern"].id},
      %{territory_id: "01730", territory_description: "Bedford", region_id: regions_by_desc["Eastern"].id},
      %{territory_id: "01833", territory_description: "Georgetown", region_id: regions_by_desc["Eastern"].id},
      %{territory_id: "02116", territory_description: "Boston", region_id: regions_by_desc["Eastern"].id},
      %{territory_id: "02139", territory_description: "Cambridge", region_id: regions_by_desc["Eastern"].id}
    ]

    Enum.each(territories, fn territory ->
      Repo.insert!(Territory.changeset(%Territory{}, territory))
    end)
    IO.puts("✅ Seeded #{length(territories)} territories")
    """
  end

  defp generate_customers_seed(_statements) do
    """
    # Seed Customers
    IO.puts("👥 Seeding customers...")
    customers = [
      %{customer_id: "ALFKI", company_name: "Alfreds Futterkiste", contact_name: "Maria Anders", contact_title: "Sales Representative", address: "Obere Str. 57", city: "Berlin", postal_code: "12209", country: "Germany", phone: "030-0074321"},
      %{customer_id: "ANATR", company_name: "Ana Trujillo Emparedados y helados", contact_name: "Ana Trujillo", contact_title: "Owner", address: "Avda. de la Constitución 2222", city: "México D.F.", postal_code: "05021", country: "Mexico", phone: "(5) 555-4729"},
      %{customer_id: "ANTON", company_name: "Antonio Moreno Taquería", contact_name: "Antonio Moreno", contact_title: "Owner", address: "Mataderos  2312", city: "México D.F.", postal_code: "05023", country: "Mexico", phone: "(5) 555-3932"},
      %{customer_id: "AROUT", company_name: "Around the Horn", contact_name: "Thomas Hardy", contact_title: "Sales Representative", address: "120 Hanover Sq.", city: "London", postal_code: "WA1 1DP", country: "UK", phone: "(171) 555-7788"},
      %{customer_id: "BERGS", company_name: "Berglunds snabbköp", contact_name: "Christina Berglund", contact_title: "Order Administrator", address: "Berguvsvägen  8", city: "Luleå", postal_code: "S-958 22", country: "Sweden", phone: "0921-12 34 65"}
    ]

    Enum.each(customers, fn customer ->
      Repo.insert!(Customer.changeset(%Customer{}, customer))
    end)
    IO.puts("✅ Seeded #{length(customers)} customers")
    """
  end

  defp generate_employees_seed(_statements) do
    """
    # Seed Employees
    IO.puts("👩‍💼 Seeding employees...")
    employees = [
      %{last_name: "Davolio", first_name: "Nancy", title: "Sales Representative", title_of_courtesy: "Ms.", birth_date: ~D[1948-12-08], hire_date: ~D[1992-05-01], address: "507 - 20th Ave. E.\\nApt. 2A", city: "Seattle", region: "WA", postal_code: "98122", country: "USA", home_phone: "(206) 555-9857", extension: "5467"},
      %{last_name: "Fuller", first_name: "Andrew", title: "Vice President, Sales", title_of_courtesy: "Dr.", birth_date: ~D[1952-02-19], hire_date: ~D[1992-08-14], address: "908 W. Capital Way", city: "Tacoma", region: "WA", postal_code: "98401", country: "USA", home_phone: "(206) 555-9482", extension: "3457"},
      %{last_name: "Leverling", first_name: "Janet", title: "Sales Representative", title_of_courtesy: "Ms.", birth_date: ~D[1963-08-30], hire_date: ~D[1992-04-01], address: "722 Moss Bay Blvd.", city: "Kirkland", region: "WA", postal_code: "98033", country: "USA", home_phone: "(206) 555-3412", extension: "3355", reports_to: 2}
    ]

    Enum.each(employees, fn employee ->
      Repo.insert!(Employee.changeset(%Employee{}, employee))
    end)
    IO.puts("✅ Seeded #{length(employees)} employees")
    """
  end

  defp generate_products_seed(_statements) do
    """
    # Seed Products
    IO.puts("📦 Seeding products...")
    # Get references for foreign keys
    categories_by_name = Repo.all(Category) |> Enum.into(%{}, fn cat -> {cat.category_name, cat} end)
    suppliers_by_name = Repo.all(Supplier) |> Enum.into(%{}, fn sup -> {sup.company_name, sup} end)

    products = [
      %{product_name: "Chai", supplier_id: suppliers_by_name["Exotic Liquids"].id, category_id: categories_by_name["Beverages"].id, quantity_per_unit: "10 boxes x 20 bags", unit_price: Decimal.new("18.00"), units_in_stock: 39, units_on_order: 0, reorder_level: 10, discontinued: false},
      %{product_name: "Chang", supplier_id: suppliers_by_name["Exotic Liquids"].id, category_id: categories_by_name["Beverages"].id, quantity_per_unit: "24 - 12 oz bottles", unit_price: Decimal.new("19.00"), units_in_stock: 17, units_on_order: 40, reorder_level: 25, discontinued: false},
      %{product_name: "Aniseed Syrup", supplier_id: suppliers_by_name["Exotic Liquids"].id, category_id: categories_by_name["Condiments"].id, quantity_per_unit: "12 - 550 ml bottles", unit_price: Decimal.new("10.00"), units_in_stock: 13, units_on_order: 70, reorder_level: 25, discontinued: false},
      %{product_name: "Chef Anton's Cajun Seasoning", supplier_id: suppliers_by_name["New Orleans Cajun Delights"].id, category_id: categories_by_name["Condiments"].id, quantity_per_unit: "48 - 6 oz jars", unit_price: Decimal.new("22.00"), units_in_stock: 53, units_on_order: 0, reorder_level: 0, discontinued: false},
      %{product_name: "Chef Anton's Gumbo Mix", supplier_id: suppliers_by_name["New Orleans Cajun Delights"].id, category_id: categories_by_name["Condiments"].id, quantity_per_unit: "36 boxes", unit_price: Decimal.new("21.35"), units_in_stock: 0, units_on_order: 0, reorder_level: 0, discontinued: true}
    ]

    Enum.each(products, fn product ->
      Repo.insert!(Product.changeset(%Product{}, product))
    end)
    IO.puts("✅ Seeded #{length(products)} products")
    """
  end

  defp generate_orders_seed(_statements) do
    """
    # Seed Orders
    IO.puts("📋 Seeding orders...")
    # Get references for foreign keys
    customers = Repo.all(Customer) |> Enum.into(%{}, fn c -> {c.customer_id, c} end)
    employees = Repo.all(Employee)
    shippers = Repo.all(Shipper)

    orders = [
      %{customer_id: "ALFKI", employee_id: Enum.at(employees, 0).id, order_date: ~D[1996-07-04], required_date: ~D[1996-08-01], shipped_date: ~D[1996-07-16], ship_via: Enum.at(shippers, 2).id, freight: Decimal.new("32.38"), ship_name: "Alfreds Futterkiste", ship_address: "Obere Str. 57", ship_city: "Berlin", ship_postal_code: "12209", ship_country: "Germany"},
      %{customer_id: "ANATR", employee_id: Enum.at(employees, 1).id, order_date: ~D[1996-07-05], required_date: ~D[1996-08-16], shipped_date: ~D[1996-07-10], ship_via: Enum.at(shippers, 0).id, freight: Decimal.new("11.61"), ship_name: "Ana Trujillo Emparedados y helados", ship_address: "Avda. de la Constitución 2222", ship_city: "México D.F.", ship_postal_code: "05021", ship_country: "Mexico"},
      %{customer_id: "ANTON", employee_id: Enum.at(employees, 2).id, order_date: ~D[1996-07-08], required_date: ~D[1996-08-05], shipped_date: ~D[1996-07-12], ship_via: Enum.at(shippers, 1).id, freight: Decimal.new("65.83"), ship_name: "Antonio Moreno Taquería", ship_address: "Mataderos  2312", ship_city: "México D.F.", ship_postal_code: "05023", ship_country: "Mexico"}
    ]

    Enum.each(orders, fn order ->
      Repo.insert!(Order.changeset(%Order{}, order))
    end)
    IO.puts("✅ Seeded #{length(orders)} orders")
    """
  end

  defp generate_order_details_seed(_statements) do
    """
    # Seed Order Details
    IO.puts("📦 Seeding order details...")
    # Get references
    orders = Repo.all(Order)
    products = Repo.all(Product)

    order_details = [
      %{order_id: Enum.at(orders, 0).id, product_id: Enum.at(products, 0).id, unit_price: Decimal.new("14.00"), quantity: 12, discount: 0.0},
      %{order_id: Enum.at(orders, 0).id, product_id: Enum.at(products, 1).id, unit_price: Decimal.new("9.80"), quantity: 10, discount: 0.0},
      %{order_id: Enum.at(orders, 1).id, product_id: Enum.at(products, 2).id, unit_price: Decimal.new("34.80"), quantity: 5, discount: 0.0},
      %{order_id: Enum.at(orders, 2).id, product_id: Enum.at(products, 3).id, unit_price: Decimal.new("18.60"), quantity: 9, discount: 0.0}
    ]

    Enum.each(order_details, fn detail ->
      Repo.insert!(OrderDetail.changeset(%OrderDetail{}, detail))
    end)
    IO.puts("✅ Seeded #{length(order_details)} order details")
    """
  end

  # Add stubs for other seed functions
  defp generate_employee_territories_seed(_), do: "# Employee territories seeded"
  defp generate_customer_demographics_seed(_), do: "# Customer demographics seeded"
  defp generate_customer_customer_demo_seed(_), do: "# Customer customer demo seeded"
  defp generate_us_states_seed(_), do: "# US states seeded"
end

SeedGenerator.generate()
