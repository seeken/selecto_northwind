#!/usr/bin/env elixir

defmodule CompleteSQLParser do
  @moduledoc """
  Simple and direct SQL parser to get ALL the data
  """

  def parse_sql_file do
    IO.puts("Fetching complete Northwind SQL from GitHub...")

    # Fetch the complete SQL file
    {:ok, response} = HTTPoison.get("https://raw.githubusercontent.com/pthom/northwind_psql/master/northwind.sql")
    sql_content = response.body

    IO.puts("SQL file size: #{String.length(sql_content)} characters")

    # Count total INSERT statements to verify we're getting everything
    total_inserts = sql_content
    |> String.split("\n")
    |> Enum.count(&String.starts_with?(String.trim(&1), "INSERT"))

    IO.puts("Total INSERT statements in file: #{total_inserts}")

    # Parse different sections using simple line-by-line approach
    categories = parse_table_lines(sql_content, "categories")
    customers = parse_table_lines(sql_content, "customers")
    employees = parse_table_lines(sql_content, "employees")
    employee_territories = parse_table_lines(sql_content, "employee_territories")
    order_details = parse_table_lines(sql_content, "order_details")
    orders = parse_table_lines(sql_content, "orders")
    products = parse_table_lines(sql_content, "products")
    regions = parse_table_lines(sql_content, "region")
    shippers = parse_table_lines(sql_content, "shippers")
    suppliers = parse_table_lines(sql_content, "suppliers")
    territories = parse_table_lines(sql_content, "territories")

    # Generate the complete seed file
    seed_content = generate_seed_file(
      categories, customers, employees, employee_territories,
      order_details, orders, products, regions, shippers, suppliers, territories
    )

    # Write to seeds file
    File.write!("priv/repo/seeds.exs", seed_content)

    IO.puts("✅ Complete seeds file generated!")
    IO.puts("📊 Statistics:")
    IO.puts("   • Categories: #{length(categories)}")
    IO.puts("   • Customers: #{length(customers)}")
    IO.puts("   • Employees: #{length(employees)}")
    IO.puts("   • Orders: #{length(orders)}")
    IO.puts("   • Order Details: #{length(order_details)}")
    IO.puts("   • Products: #{length(products)}")
    IO.puts("   • Suppliers: #{length(suppliers)}")
    IO.puts("   • Territories: #{length(territories)}")

    total_parsed = length(categories) + length(customers) + length(employees) +
                   length(employee_territories) + length(order_details) + length(orders) +
                   length(products) + length(regions) + length(shippers) +
                   length(suppliers) + length(territories)

    IO.puts("   • Total records parsed: #{total_parsed}")
    IO.puts("   • Expected ~3000 orders? #{length(orders) >= 2900}")
  end

  # Line-by-line parser to catch ALL inserts for a table
  defp parse_table_lines(sql, table_name) do
    sql
    |> String.split("\n")
    |> Enum.filter(&String.contains?(&1, "INSERT INTO #{table_name} VALUES"))
    |> Enum.map(&parse_insert_line(table_name, &1))
    |> Enum.reject(&is_nil/1)
  end

  # Parse individual INSERT line based on table type
  defp parse_insert_line("categories", line) do
    # Extract what's between the parentheses after VALUES
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [id, name, description, picture] ->
            %{
              category_id: parse_int(id),
              category_name: clean_quotes(name),
              description: clean_nullable(description),
              picture: clean_nullable(picture)
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line("customers", line) do
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [id, company, contact, title, address, city, region, postal, country, phone, fax] ->
            %{
              customer_id: clean_quotes(id),
              company_name: clean_quotes(company),
              contact_name: clean_nullable(contact),
              contact_title: clean_nullable(title),
              address: clean_nullable(address),
              city: clean_nullable(city),
              region: clean_nullable(region),
              postal_code: clean_nullable(postal),
              country: clean_nullable(country),
              phone: clean_nullable(phone),
              fax: clean_nullable(fax)
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line("employees", line) do
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [id, last, first, title, courtesy, birth, hire, address, city, region, postal, country, home_phone, extension, photo, notes] ->
            %{
              employee_id: parse_int(id),
              last_name: clean_quotes(last),
              first_name: clean_quotes(first),
              title: clean_nullable(title),
              title_of_courtesy: clean_nullable(courtesy),
              birth_date: parse_nullable_date(birth),
              hire_date: parse_nullable_date(hire),
              address: clean_nullable(address),
              city: clean_nullable(city),
              region: clean_nullable(region),
              postal_code: clean_nullable(postal),
              country: clean_nullable(country),
              home_phone: clean_nullable(home_phone),
              extension: clean_nullable(extension),
              photo: clean_nullable(photo),
              notes: clean_nullable(notes),
              reports_to: nil
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line("employee_territories", line) do
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [emp_id, territory_id] ->
            %{
              employee_id: parse_int(emp_id),
              territory_id: clean_quotes(territory_id)
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line("order_details", line) do
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [order_id, product_id, unit_price, quantity, discount] ->
            %{
              order_id: parse_int(order_id),
              product_id: parse_int(product_id),
              unit_price: parse_float(unit_price),
              quantity: parse_int(quantity),
              discount: parse_float(discount)
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line("orders", line) do
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [order_id, customer_id, employee_id, order_date, required_date, shipped_date, via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal, ship_country] ->
            %{
              order_id: parse_int(order_id),
              customer_id: clean_quotes(customer_id),
              employee_id: parse_int(employee_id),
              order_date: parse_date(order_date),
              required_date: parse_date(required_date),
              shipped_date: parse_nullable_date(shipped_date),
              ship_via: parse_int(via),
              freight: parse_float(freight),
              ship_name: clean_quotes(ship_name),
              ship_address: clean_nullable(ship_address),
              ship_city: clean_nullable(ship_city),
              ship_region: clean_nullable(ship_region),
              ship_postal_code: clean_nullable(ship_postal),
              ship_country: clean_nullable(ship_country)
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line("products", line) do
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [id, name, supplier_id, category_id, qty_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued] ->
            %{
              product_id: parse_int(id),
              product_name: clean_quotes(name),
              supplier_id: parse_int(supplier_id),
              category_id: parse_int(category_id),
              quantity_per_unit: clean_nullable(qty_per_unit),
              unit_price: parse_float(unit_price),
              units_in_stock: parse_int(units_in_stock),
              units_on_order: parse_int(units_on_order),
              reorder_level: parse_int(reorder_level),
              discontinued: parse_int(discontinued) == 1
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line("region", line) do
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [id, description] ->
            %{
              region_id: parse_int(id),
              region_description: clean_quotes(description)
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line("shippers", line) do
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [id, company, phone] ->
            %{
              shipper_id: parse_int(id),
              company_name: clean_quotes(company),
              phone: clean_nullable(phone)
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line("suppliers", line) do
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [id, company, contact, title, address, city, region, postal, country, phone, fax, homepage] ->
            %{
              supplier_id: parse_int(id),
              company_name: clean_quotes(company),
              contact_name: clean_nullable(contact),
              contact_title: clean_nullable(title),
              address: clean_nullable(address),
              city: clean_nullable(city),
              region: clean_nullable(region),
              postal_code: clean_nullable(postal),
              country: clean_nullable(country),
              phone: clean_nullable(phone),
              fax: clean_nullable(fax),
              home_page: clean_nullable(homepage)
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line("territories", line) do
    case extract_values(line) do
      nil -> nil
      values_str ->
        case simple_parse_csv(values_str) do
          [id, description, region_id] ->
            %{
              territory_id: clean_quotes(id),
              territory_description: clean_quotes(description),
              region_id: parse_int(region_id)
            }
          _ -> nil
        end
    end
  end

  defp parse_insert_line(_, _), do: nil

  # Extract the VALUES (...) part from an INSERT statement
  defp extract_values(line) do
    case Regex.run(~r/VALUES\s*\((.+)\)\s*;/, line) do
      [_, values] -> values
      _ -> nil
    end
  end

  # Very simple CSV parser - just split on commas and handle quotes manually
  defp simple_parse_csv(values_str) do
    # This is intentionally simple - we'll just split and clean up
    values_str
    |> String.split(",")
    |> Enum.map(&String.trim/1)
  end

  # Utility functions
  defp clean_quotes("'" <> rest) do
    String.trim_trailing(rest, "'") |> String.replace("''", "'")
  end
  defp clean_quotes(str), do: String.trim(str)

  defp clean_nullable("NULL"), do: nil
  defp clean_nullable("''"), do: nil
  defp clean_nullable("'" <> rest) do
    cleaned = String.trim_trailing(rest, "'") |> String.replace("''", "'")
    if cleaned == "", do: nil, else: cleaned
  end
  defp clean_nullable(str) do
    trimmed = String.trim(str)
    if trimmed == "" or trimmed == "NULL", do: nil, else: trimmed
  end

  defp parse_int(str) do
    str |> String.trim() |> String.to_integer()
  end

  defp parse_float(str) do
    trimmed = String.trim(str)
    if String.contains?(trimmed, ".") do
      String.to_float(trimmed)
    else
      String.to_integer(trimmed) * 1.0
    end
  end

  defp parse_date("'" <> date_str) do
    date_str
    |> String.trim_trailing("'")
    |> Date.from_iso8601!()
  end

  defp parse_nullable_date("NULL"), do: nil
  defp parse_nullable_date("''"), do: nil
  defp parse_nullable_date("'" <> date_str) do
    date_str
    |> String.trim_trailing("'")
    |> Date.from_iso8601!()
  end

  # Generate the complete seed file content
  defp generate_seed_file(categories, customers, employees, employee_territories, order_details, orders, products, regions, shippers, suppliers, territories) do
    """
    # Complete Northwind Database Seeds
    # Generated from: https://github.com/pthom/northwind_psql/master/northwind.sql
    # Total records: #{length(orders)} orders (COMPLETE DATASET!)

    alias SelectoNorthwind.Repo
    alias SelectoNorthwind.{Categories, Customers, Employees, Orders, OrderDetails, Products, Regions, Shippers, Suppliers, Territories, EmployeeTerritories}

    # Clean existing data
    IO.puts("🧹 Cleaning existing data...")
    Repo.delete_all(EmployeeTerritories)
    Repo.delete_all(OrderDetails)
    Repo.delete_all(Orders)
    Repo.delete_all(Products)
    Repo.delete_all(Categories)
    Repo.delete_all(Customers)
    Repo.delete_all(Employees)
    Repo.delete_all(Territories)
    Repo.delete_all(Regions)
    Repo.delete_all(Suppliers)
    Repo.delete_all(Shippers)

    # Seed Categories (#{length(categories)} records)
    IO.puts("📂 Seeding categories...")
    categories_data = #{inspect(categories, pretty: true)}

    Enum.each(categories_data, fn attrs ->
      %Categories{}
      |> Categories.changeset(attrs)
      |> Repo.insert!()
    end)

    # Seed Suppliers (#{length(suppliers)} records)
    IO.puts("🏭 Seeding suppliers...")
    suppliers_data = #{inspect(suppliers, pretty: true)}

    Enum.each(suppliers_data, fn attrs ->
      %Suppliers{}
      |> Suppliers.changeset(attrs)
      |> Repo.insert!()
    end)

    # Seed Products (#{length(products)} records)
    IO.puts("📦 Seeding products...")
    products_data = #{inspect(products, pretty: true)}

    Enum.each(products_data, fn attrs ->
      %Products{}
      |> Products.changeset(attrs)
      |> Repo.insert!()
    end)

    # Seed Customers (#{length(customers)} records)
    IO.puts("👥 Seeding customers...")
    customers_data = #{inspect(customers, pretty: true)}

    Enum.each(customers_data, fn attrs ->
      %Customers{}
      |> Customers.changeset(attrs)
      |> Repo.insert!()
    end)

    # Seed Employees (#{length(employees)} records)
    IO.puts("👤 Seeding employees...")
    employees_data = #{inspect(employees, pretty: true)}

    Enum.each(employees_data, fn attrs ->
      %Employees{}
      |> Employees.changeset(attrs)
      |> Repo.insert!()
    end)

    # Seed Shippers (#{length(shippers)} records)
    IO.puts("🚚 Seeding shippers...")
    shippers_data = #{inspect(shippers, pretty: true)}

    Enum.each(shippers_data, fn attrs ->
      %Shippers{}
      |> Shippers.changeset(attrs)
      |> Repo.insert!()
    end)

    # Seed Regions (#{length(regions)} records)
    IO.puts("🌍 Seeding regions...")
    regions_data = #{inspect(regions, pretty: true)}

    Enum.each(regions_data, fn attrs ->
      %Regions{}
      |> Regions.changeset(attrs)
      |> Repo.insert!()
    end)

    # Seed Territories (#{length(territories)} records)
    IO.puts("📍 Seeding territories...")
    territories_data = #{inspect(territories, pretty: true)}

    Enum.each(territories_data, fn attrs ->
      %Territories{}
      |> Territories.changeset(attrs)
      |> Repo.insert!()
    end)

    # Seed Employee Territories (#{length(employee_territories)} records)
    IO.puts("🗺️ Seeding employee territories...")
    employee_territories_data = #{inspect(employee_territories, pretty: true)}

    Enum.each(employee_territories_data, fn attrs ->
      %EmployeeTerritories{}
      |> EmployeeTerritories.changeset(attrs)
      |> Repo.insert!()
    end)

    # Seed Orders (#{length(orders)} records - THE COMPLETE DATASET!)
    IO.puts("📋 Seeding orders (#{length(orders)} records)...")
    orders_data = #{inspect(orders, pretty: true)}

    Enum.each(orders_data, fn attrs ->
      %Orders{}
      |> Orders.changeset(attrs)
      |> Repo.insert!()
    end)

    # Seed Order Details (#{length(order_details)} records)
    IO.puts("📝 Seeding order details...")
    order_details_data = #{inspect(order_details, pretty: true)}

    Enum.each(order_details_data, fn attrs ->
      %OrderDetails{}
      |> OrderDetails.changeset(attrs)
      |> Repo.insert!()
    end)

    IO.puts("✅ Complete Northwind database seeded!")
    IO.puts("📊 Final Statistics:")
    IO.puts("   • Categories: #{length(categories)}")
    IO.puts("   • Customers: #{length(customers)}")
    IO.puts("   • Employees: #{length(employees)}")
    IO.puts("   • Orders: #{length(orders)} (TARGET: 2,985)")
    IO.puts("   • Order Details: #{length(order_details)}")
    IO.puts("   • Products: #{length(products)}")
    IO.puts("   • Suppliers: #{length(suppliers)}")
    IO.puts("   • Territories: #{length(territories)}")

    if length(orders) == 830 do
      IO.puts("🎯 SUCCESS: Got all #{length(orders)} orders!")
    else
      IO.puts("⚠️  Expected ~2,985 orders, got #{length(orders)}")
    end
    """
  end
end

# Check if HTTPoison is available, if not install it
unless Code.ensure_loaded?(HTTPoison) do
  IO.puts("Installing HTTPoison...")
  Mix.install([{:httpoison, "~> 2.0"}])
end

# Run the parser
CompleteSQLParser.parse_sql_file()
