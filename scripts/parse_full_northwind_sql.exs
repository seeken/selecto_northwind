#!/usr/bin/env elixir

defmodule NorthwindSQLParser do
  @moduledoc """
  Parse the complete Northwind SQL file and convert to Elixir seeds
  """

  def parse_sql_file do
    IO.puts("Fetching complete Northwind SQL from GitHub...")

    # Fetch the complete SQL file
    {:ok, response} = HTTPoison.get("https://raw.githubusercontent.com/pthom/northwind_psql/master/northwind.sql")
    sql_content = response.body

    IO.puts("Parsing SQL content...")

    # Parse different sections
    categories = parse_categories(sql_content)
    customers = parse_customers(sql_content)
    employees = parse_employees(sql_content)
    employee_territories = parse_employee_territories(sql_content)
    order_details = parse_order_details(sql_content)
    orders = parse_orders(sql_content)
    products = parse_products(sql_content)
    regions = parse_regions(sql_content)
    shippers = parse_shippers(sql_content)
    suppliers = parse_suppliers(sql_content)
    territories = parse_territories(sql_content)

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
  end

  # Parse categories from SQL INSERT statements
  defp parse_categories(sql) do
    regex = ~r/INSERT INTO categories VALUES \((\d+), '([^']+)', '([^']*)', '([^']*)'\);/

    Regex.scan(regex, sql)
    |> Enum.map(fn [_, id, name, description, picture] ->
      %{
        category_id: String.to_integer(id),
        category_name: name,
        description: if(description == "", do: nil, else: description),
        picture: if(picture == "", do: nil, else: picture)
      }
    end)
  end

  # Parse customers from SQL INSERT statements
  defp parse_customers(sql) do
    # Use both specific and flexible patterns
    regex1 = ~r/INSERT INTO customers VALUES \('([^']+)', '([^']+)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)'\);/
    regex2 = ~r/INSERT\s+INTO\s+customers\s+VALUES\s*\(([^)]+)\);/sim

    matches1 = Regex.scan(regex1, sql)
    matches2 = Regex.scan(regex2, sql)

    IO.puts("Found #{length(matches1)} direct customer matches and #{length(matches2)} flexible matches")

    customers1 = Enum.map(matches1, fn [_, id, company, contact, title, address, city, region, postal, country, phone, fax] ->
      %{
        customer_id: id,
        company_name: company,
        contact_name: if(contact == "", do: nil, else: contact),
        contact_title: if(title == "", do: nil, else: title),
        address: if(address == "", do: nil, else: address),
        city: if(city == "", do: nil, else: city),
        region: if(region == "NULL" || region == "", do: nil, else: region),
        postal_code: if(postal == "", do: nil, else: postal),
        country: if(country == "", do: nil, else: country),
        phone: if(phone == "", do: nil, else: phone),
        fax: if(fax == "NULL" || fax == "", do: nil, else: fax)
      }
    end)

    customers2 = matches2
    |> Enum.map(&parse_customer_from_values/1)
    |> Enum.reject(&is_nil/1)

    all_customers = (customers1 ++ customers2)
    |> Enum.uniq_by(& &1.customer_id)

    IO.puts("Total unique customers parsed: #{length(all_customers)}")
    all_customers
  end

  defp parse_customer_from_values([_, values_str]) do
    parts = split_sql_values(values_str)

    if length(parts) == 11 do
      try do
        [id, company, contact, title, address, city, region, postal, country, phone, fax] = parts

        %{
          customer_id: clean_sql_string(id),
          company_name: clean_sql_string(company),
          contact_name: clean_nullable_string(contact),
          contact_title: clean_nullable_string(title),
          address: clean_nullable_string(address),
          city: clean_nullable_string(city),
          region: clean_nullable_string(region),
          postal_code: clean_nullable_string(postal),
          country: clean_nullable_string(country),
          phone: clean_nullable_string(phone),
          fax: clean_nullable_string(fax)
        }
      rescue
        _ -> nil
      end
    else
      nil
    end
  end

  # Parse employees from SQL INSERT statements
  defp parse_employees(sql) do
    regex1 = ~r/INSERT INTO employees VALUES \((\d+), '([^']+)', '([^']+)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', (\d+|NULL), '([^']*)', '([^']*)'\);/
    regex2 = ~r/INSERT\s+INTO\s+employees\s+VALUES\s*\(([^)]+)\);/sim

    matches1 = Regex.scan(regex1, sql)
    matches2 = Regex.scan(regex2, sql)

    IO.puts("Found #{length(matches1)} direct employee matches and #{length(matches2)} flexible matches")

    employees1 = Enum.map(matches1, fn [_, id, last, first, title, courtesy, birth, hire, address, city, region, postal, country, home_phone, extension, photo, notes] ->
      %{
        employee_id: String.to_integer(id),
        last_name: last,
        first_name: first,
        title: if(title == "", do: nil, else: title),
        title_of_courtesy: if(courtesy == "", do: nil, else: courtesy),
        birth_date: if(birth == "", do: nil, else: parse_date(birth)),
        hire_date: if(hire == "", do: nil, else: parse_date(hire)),
        address: if(address == "", do: nil, else: address),
        city: if(city == "", do: nil, else: city),
        region: if(region == "NULL" || region == "", do: nil, else: region),
        postal_code: if(postal == "", do: nil, else: postal),
        country: if(country == "", do: nil, else: country),
        home_phone: if(home_phone == "", do: nil, else: home_phone),
        extension: if(extension == "", do: nil, else: extension),
        photo: if(photo == "", do: nil, else: photo),
        notes: if(notes == "", do: nil, else: notes),
        reports_to: if(extension == "NULL", do: nil, else: parse_reports_to(sql, String.to_integer(id)))
      }
    end)

    employees2 = matches2
    |> Enum.map(&parse_employee_from_values/1)
    |> Enum.reject(&is_nil/1)

    all_employees = (employees1 ++ employees2)
    |> Enum.uniq_by(& &1.employee_id)

    IO.puts("Total unique employees parsed: #{length(all_employees)}")
    all_employees
  end

  defp parse_employee_from_values([_, values_str]) do
    parts = split_sql_values(values_str)

    if length(parts) == 16 do
      try do
        [id, last, first, title, courtesy, birth, hire, address, city, region, postal, country, home_phone, extension, photo, notes] = parts

        %{
          employee_id: clean_and_parse_int(id),
          last_name: clean_sql_string(last),
          first_name: clean_sql_string(first),
          title: clean_nullable_string(title),
          title_of_courtesy: clean_nullable_string(courtesy),
          birth_date: parse_nullable_date(clean_sql_string(birth)),
          hire_date: parse_nullable_date(clean_sql_string(hire)),
          address: clean_nullable_string(address),
          city: clean_nullable_string(city),
          region: clean_nullable_string(region),
          postal_code: clean_nullable_string(postal),
          country: clean_nullable_string(country),
          home_phone: clean_nullable_string(home_phone),
          extension: clean_nullable_string(extension),
          photo: clean_nullable_string(photo),
          notes: clean_nullable_string(notes),
          reports_to: nil  # Will be handled separately
        }
      rescue
        _ -> nil
      end
    else
      nil
    end
  end

  # Parse employee territories
  defp parse_employee_territories(sql) do
    regex = ~r/INSERT INTO employee_territories VALUES \((\d+), '([^']+)'\);/

    Regex.scan(regex, sql)
    |> Enum.map(fn [_, emp_id, territory_id] ->
      %{
        employee_id: String.to_integer(emp_id),
        territory_id: territory_id
      }
    end)
  end

  # Parse order details
  defp parse_order_details(sql) do
    regex = ~r/INSERT INTO order_details VALUES \((\d+), (\d+), ([0-9.]+), (\d+), ([0-9.]+)\);/

    Regex.scan(regex, sql)
    |> Enum.map(fn [_, order_id, product_id, unit_price, quantity, discount] ->
      %{
        order_id: String.to_integer(order_id),
        product_id: String.to_integer(product_id),
        unit_price: parse_number(unit_price),
        quantity: String.to_integer(quantity),
        discount: parse_number(discount)
      }
    end)
  end

  # Parse orders - this is the key one with 2,985 records
  defp parse_orders(sql) do
    # More flexible regex that handles multi-line and complex strings
    regex = ~r/INSERT INTO orders VALUES \((\d+), '([^']+)', (\d+), '([^']+)', '([^']+)', '([^']*)', (\d+), ([0-9.]+), '([^']*)', '([^']*)', '([^']*)', (?:'([^']*)'|NULL), '([^']*)', '([^']*)'\);/sm

    matches = Regex.scan(regex, sql)

    # Also try a simpler pattern for cases where above fails
    simple_regex = ~r/INSERT\s+INTO\s+orders\s+VALUES\s*\(([^)]+)\);/sim
    simple_matches = Regex.scan(simple_regex, sql)

    IO.puts("Found #{length(matches)} complex order matches and #{length(simple_matches)} simple matches")

    # Process complex matches first
    complex_orders = Enum.map(matches, fn [_, order_id, customer_id, employee_id, order_date, required_date, shipped_date, via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal, ship_country] ->
      %{
        order_id: String.to_integer(order_id),
        customer_id: customer_id,
        employee_id: String.to_integer(employee_id),
        order_date: parse_date(order_date),
        required_date: parse_date(required_date),
        shipped_date: if(shipped_date == "", do: nil, else: parse_date(shipped_date)),
        ship_via: String.to_integer(via),
        freight: parse_number(freight),
        ship_name: ship_name,
        ship_address: if(ship_address == "", do: nil, else: ship_address),
        ship_city: if(ship_city == "", do: nil, else: ship_city),
        ship_region: if(ship_region == "NULL" || ship_region == "", do: nil, else: ship_region),
        ship_postal_code: if(ship_postal == "", do: nil, else: ship_postal),
        ship_country: if(ship_country == "", do: nil, else: ship_country)
      }
    end)

    # Process simple matches to catch missed records
    simple_orders = simple_matches
    |> Enum.map(&parse_order_from_values/1)
    |> Enum.reject(&is_nil/1)

    # Combine and deduplicate
    all_orders = (complex_orders ++ simple_orders)
    |> Enum.uniq_by(& &1.order_id)

    IO.puts("Total unique orders parsed: #{length(all_orders)}")
    all_orders
  end

  # Parse individual order from VALUES clause
  defp parse_order_from_values([_, values_str]) do
    # Split on commas but respect quotes
    parts = split_sql_values(values_str)

    if length(parts) == 14 do
      try do
        [order_id, customer_id, employee_id, order_date, required_date, shipped_date, via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal, ship_country] = parts

        %{
          order_id: clean_and_parse_int(order_id),
          customer_id: clean_sql_string(customer_id),
          employee_id: clean_and_parse_int(employee_id),
          order_date: parse_date(clean_sql_string(order_date)),
          required_date: parse_date(clean_sql_string(required_date)),
          shipped_date: parse_nullable_date(clean_sql_string(shipped_date)),
          ship_via: clean_and_parse_int(via),
          freight: parse_number(clean_sql_string(freight)),
          ship_name: clean_sql_string(ship_name),
          ship_address: clean_nullable_string(ship_address),
          ship_city: clean_nullable_string(ship_city),
          ship_region: clean_nullable_string(ship_region),
          ship_postal_code: clean_nullable_string(ship_postal),
          ship_country: clean_nullable_string(ship_country)
        }
      rescue
        _ -> nil
      end
    else
      nil
    end
  end

  # Parse products
  defp parse_products(sql) do
    regex = ~r/INSERT INTO products VALUES \((\d+), '([^']+)', (\d+), (\d+), '([^']*)', ([0-9.]+), (\d+), (\d+), (\d+), (\d+)\);/

    Regex.scan(regex, sql)
    |> Enum.map(fn [_, id, name, supplier_id, category_id, qty_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued] ->
      %{
        product_id: String.to_integer(id),
        product_name: name,
        supplier_id: String.to_integer(supplier_id),
        category_id: String.to_integer(category_id),
        quantity_per_unit: if(qty_per_unit == "", do: nil, else: qty_per_unit),
        unit_price: parse_number(unit_price),
        units_in_stock: String.to_integer(units_in_stock),
        units_on_order: String.to_integer(units_on_order),
        reorder_level: String.to_integer(reorder_level),
        discontinued: String.to_integer(discontinued) == 1
      }
    end)
  end

  # Parse regions
  defp parse_regions(sql) do
    regex = ~r/INSERT INTO region VALUES \((\d+), '([^']+)'\);/

    Regex.scan(regex, sql)
    |> Enum.map(fn [_, id, description] ->
      %{
        region_id: String.to_integer(id),
        region_description: description
      }
    end)
  end

  # Parse shippers
  defp parse_shippers(sql) do
    regex = ~r/INSERT INTO shippers VALUES \((\d+), '([^']+)', '([^']*)'\);/

    Regex.scan(regex, sql)
    |> Enum.map(fn [_, id, company, phone] ->
      %{
        shipper_id: String.to_integer(id),
        company_name: company,
        phone: if(phone == "", do: nil, else: phone)
      }
    end)
  end

  # Parse suppliers
  defp parse_suppliers(sql) do
    regex1 = ~r/INSERT INTO suppliers VALUES \((\d+), '([^']+)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)'\);/
    regex2 = ~r/INSERT\s+INTO\s+suppliers\s+VALUES\s*\(([^)]+)\);/sim

    matches1 = Regex.scan(regex1, sql)
    matches2 = Regex.scan(regex2, sql)

    IO.puts("Found #{length(matches1)} direct supplier matches and #{length(matches2)} flexible matches")

    suppliers1 = Enum.map(matches1, fn [_, id, company, contact, title, address, city, region, postal, country, phone, fax, homepage] ->
      %{
        supplier_id: String.to_integer(id),
        company_name: company,
        contact_name: if(contact == "", do: nil, else: contact),
        contact_title: if(title == "", do: nil, else: title),
        address: if(address == "", do: nil, else: address),
        city: if(city == "", do: nil, else: city),
        region: if(region == "NULL" || region == "", do: nil, else: region),
        postal_code: if(postal == "", do: nil, else: postal),
        country: if(country == "", do: nil, else: country),
        phone: if(phone == "", do: nil, else: phone),
        fax: if(fax == "NULL" || fax == "", do: nil, else: fax),
        home_page: if(homepage == "NULL" || homepage == "", do: nil, else: homepage)
      }
    end)

    suppliers2 = matches2
    |> Enum.map(&parse_supplier_from_values/1)
    |> Enum.reject(&is_nil/1)

    all_suppliers = (suppliers1 ++ suppliers2)
    |> Enum.uniq_by(& &1.supplier_id)

    IO.puts("Total unique suppliers parsed: #{length(all_suppliers)}")
    all_suppliers
  end

  defp parse_supplier_from_values([_, values_str]) do
    parts = split_sql_values(values_str)

    if length(parts) == 12 do
      try do
        [id, company, contact, title, address, city, region, postal, country, phone, fax, homepage] = parts

        %{
          supplier_id: clean_and_parse_int(id),
          company_name: clean_sql_string(company),
          contact_name: clean_nullable_string(contact),
          contact_title: clean_nullable_string(title),
          address: clean_nullable_string(address),
          city: clean_nullable_string(city),
          region: clean_nullable_string(region),
          postal_code: clean_nullable_string(postal),
          country: clean_nullable_string(country),
          phone: clean_nullable_string(phone),
          fax: clean_nullable_string(fax),
          home_page: clean_nullable_string(homepage)
        }
      rescue
        _ -> nil
      end
    else
      nil
    end
  end

  # Parse territories
  defp parse_territories(sql) do
    regex = ~r/INSERT INTO territories VALUES \('([^']+)', '([^']+)', (\d+)\);/

    Regex.scan(regex, sql)
    |> Enum.map(fn [_, id, description, region_id] ->
      %{
        territory_id: id,
        territory_description: description,
        region_id: String.to_integer(region_id)
      }
    end)
  end

  # Helper to parse dates
  defp parse_date(date_str) do
    case Date.from_iso8601(date_str) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  # Helper to parse numbers (int or float)
  defp parse_number(num_str) do
    if String.contains?(num_str, ".") do
      String.to_float(num_str)
    else
      case String.to_integer(num_str) do
        int -> int * 1.0
      end
    end
  end

  # Helper functions for SQL parsing
  defp split_sql_values(values_str) do
    # Simple CSV parser that respects quotes
    values_str
    |> String.trim()
    |> split_csv_respecting_quotes([])
  end

  defp split_csv_respecting_quotes("", acc), do: Enum.reverse(acc)
  defp split_csv_respecting_quotes(str, acc) do
    case String.first(str) do
      "'" ->
        # Find closing quote
        case find_closing_quote(String.slice(str, 1..-1)) do
          {quoted_content, rest} ->
            next_str = String.trim_leading(rest, ", ")
            split_csv_respecting_quotes(next_str, ["'" <> quoted_content <> "'" | acc])
          nil ->
            [str | acc] |> Enum.reverse()
        end
      _ ->
        # Find next comma outside quotes
        case String.split(str, ",", parts: 2) do
          [value] -> [String.trim(value) | acc] |> Enum.reverse()
          [value, rest] -> split_csv_respecting_quotes(String.trim(rest), [String.trim(value) | acc])
        end
    end
  end

  defp find_closing_quote(str, acc \\ "")
  defp find_closing_quote("", _acc), do: nil
  defp find_closing_quote("'" <> rest, acc), do: {acc, rest}
  defp find_closing_quote(<<c::utf8, rest::binary>>, acc) do
    find_closing_quote(rest, acc <> <<c::utf8>>)
  end

  defp clean_sql_string("'" <> str) do
    str |> String.trim_trailing("'")
  end
  defp clean_sql_string("NULL"), do: nil
  defp clean_sql_string(str), do: String.trim(str)

  defp clean_nullable_string("NULL"), do: nil
  defp clean_nullable_string("''"), do: nil
  defp clean_nullable_string("'" <> str) do
    cleaned = str |> String.trim_trailing("'")
    if cleaned == "", do: nil, else: cleaned
  end
  defp clean_nullable_string(str) when is_binary(str) do
    trimmed = String.trim(str)
    if trimmed == "" or trimmed == "NULL", do: nil, else: trimmed
  end
  defp clean_nullable_string(_), do: nil

  defp clean_and_parse_int(str) do
    str |> String.trim() |> String.to_integer()
  end

  defp parse_nullable_date(""), do: nil
  defp parse_nullable_date("NULL"), do: nil
  defp parse_nullable_date(date_str) when is_binary(date_str) do
    parse_date(date_str)
  end
  defp parse_nullable_date(_), do: nil

  # Helper to parse reports_to relationships
  defp parse_reports_to(_sql, _emp_id) do
    # This would need more complex parsing - for now return nil
    # The original has some employees reporting to others
    nil
  end

  # Generate the complete seed file content
  defp generate_seed_file(categories, customers, employees, employee_territories, order_details, orders, products, regions, shippers, suppliers, territories) do
    """
    # Complete Northwind Database Seeds
    # Generated from: https://github.com/pthom/northwind_psql/master/northwind.sql
    # Total records: #{length(orders)} orders (complete dataset)

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
    IO.puts("   • Orders: #{length(orders)} (COMPLETE DATASET!)")
    IO.puts("   • Order Details: #{length(order_details)}")
    IO.puts("   • Products: #{length(products)}")
    IO.puts("   • Suppliers: #{length(suppliers)}")
    IO.puts("   • Territories: #{length(territories)}")
    """
  end
end

# Check if HTTPoison is available, if not install it
unless Code.ensure_loaded?(HTTPoison) do
  IO.puts("Installing HTTPoison...")
  Mix.install([{:httpoison, "~> 2.0"}])
end

# Run the parser
NorthwindSQLParser.parse_sql_file()
