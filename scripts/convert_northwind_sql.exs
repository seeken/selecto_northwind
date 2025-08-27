#!/usr/bin/env elixir

# Script to convert the original Northwind SQL to Elixir seed format
# Usage: elixir scripts/convert_northwind_sql.exs

defmodule NorthwindSQLConverter do
  @sql_file "/tmp/northwind.sql"
  @output_dir "priv/repo/generated_seeds"

  def run do
    IO.puts("🔄 Converting Northwind SQL to Elixir seeds...")
    File.mkdir_p!(@output_dir)

    # Read the SQL file
    sql_content = File.read!(@sql_file)

    # Extract different data types
    extract_customers(sql_content)
    extract_employees(sql_content)
    extract_products(sql_content)
    extract_orders(sql_content)
    extract_order_details(sql_content)
    extract_employee_territories(sql_content)
    extract_customer_demographics(sql_content)
    extract_us_states(sql_content)

    IO.puts("✅ Conversion complete! Check #{@output_dir}/ for generated files")
  end

  defp extract_customers(sql_content) do
    IO.puts("👥 Extracting customers...")

    # Extract INSERT INTO customers statements
    customers = Regex.scan(~r/INSERT INTO customers VALUES \(([^;]+)\);/, sql_content)

    elixir_data = Enum.map(customers, fn [_full, values] ->
      # Parse the values - this is a simplified parser
      parsed = parse_sql_values(values)
      format_customer_data(parsed)
    end)

    content = """
    # Generated customers data
    customers_data = #{inspect(elixir_data, pretty: true, limit: :infinity)}

    Enum.each(customers_data, fn customer ->
      Repo.insert!(Customer.changeset(%Customer{}, customer))
    end)
    """

    File.write!("#{@output_dir}/customers.exs", content)
  end

  defp extract_employees(sql_content) do
    IO.puts("👩‍💼 Extracting employees...")

    employees = Regex.scan(~r/INSERT INTO employees VALUES \(([^;]+)\);/, sql_content)

    elixir_data = Enum.map(employees, fn [_full, values] ->
      parsed = parse_sql_values(values)
      format_employee_data(parsed)
    end)

    content = """
    # Generated employees data
    employees_data = #{inspect(elixir_data, pretty: true, limit: :infinity)}

    Enum.each(employees_data, fn employee ->
      SeedHelper.insert_with_id(Employee, employee)
    end)
    """

    File.write!("#{@output_dir}/employees.exs", content)
  end

  defp extract_products(sql_content) do
    IO.puts("📦 Extracting products...")

    products = Regex.scan(~r/INSERT INTO products VALUES \(([^;]+)\);/, sql_content)

    elixir_data = Enum.map(products, fn [_full, values] ->
      parsed = parse_sql_values(values)
      format_product_data(parsed)
    end)

    content = """
    # Generated products data
    products_data = #{inspect(elixir_data, pretty: true, limit: :infinity)}

    Enum.each(products_data, fn product ->
      SeedHelper.insert_with_id(Product, product)
    end)
    """

    File.write!("#{@output_dir}/products.exs", content)
  end

  defp extract_orders(sql_content) do
    IO.puts("🛒 Extracting orders...")

    orders = Regex.scan(~r/INSERT INTO orders VALUES \(([^;]+)\);/, sql_content)

    elixir_data = Enum.map(orders, fn [_full, values] ->
      parsed = parse_sql_values(values)
      format_order_data(parsed)
    end)

    content = """
    # Generated orders data
    orders_data = #{inspect(elixir_data, pretty: true, limit: :infinity)}

    Enum.each(orders_data, fn order ->
      SeedHelper.insert_with_id(Order, order)
    end)
    """

    File.write!("#{@output_dir}/orders.exs", content)
  end

  defp extract_order_details(sql_content) do
    IO.puts("📋 Extracting order details...")

    order_details = Regex.scan(~r/INSERT INTO order_details VALUES \(([^;]+)\);/, sql_content)

    elixir_data = Enum.map(order_details, fn [_full, values] ->
      parsed = parse_sql_values(values)
      format_order_detail_data(parsed)
    end)

    content = """
    # Generated order details data
    order_details_data = #{inspect(elixir_data, pretty: true, limit: :infinity)}

    Enum.each(order_details_data, fn order_detail ->
      Repo.insert!(OrderDetail.changeset(%OrderDetail{}, order_detail))
    end)
    """

    File.write!("#{@output_dir}/order_details.exs", content)
  end

  defp extract_employee_territories(sql_content) do
    IO.puts("🗺️ Extracting employee territories...")

    employee_territories = Regex.scan(~r/INSERT INTO employee_territories VALUES \(([^;]+)\);/, sql_content)

    elixir_data = Enum.map(employee_territories, fn [_full, values] ->
      parsed = parse_sql_values(values)
      %{employee_id: Enum.at(parsed, 0), territory_id: Enum.at(parsed, 1)}
    end)

    content = """
    # Generated employee territories data
    employee_territories_data = #{inspect(elixir_data, pretty: true, limit: :infinity)}

    Enum.each(employee_territories_data, fn et ->
      Repo.insert!(EmployeeTerritory.changeset(%EmployeeTerritory{}, et))
    end)
    """

    File.write!("#{@output_dir}/employee_territories.exs", content)
  end

  defp extract_customer_demographics(sql_content) do
    IO.puts("📊 Extracting customer demographics...")

    # This would extract customer demographics data
    content = """
    # Generated customer demographics data
    # TODO: Extract from SQL if present
    """

    File.write!("#{@output_dir}/customer_demographics.exs", content)
  end

  defp extract_us_states(sql_content) do
    IO.puts("🇺🇸 Extracting US states...")

    us_states = Regex.scan(~r/INSERT INTO us_states VALUES \(([^;]+)\);/, sql_content)

    elixir_data = Enum.map(us_states, fn [_full, values] ->
      parsed = parse_sql_values(values)
      %{
        state_id: Enum.at(parsed, 0),
        state_name: Enum.at(parsed, 1),
        state_abbr: Enum.at(parsed, 2),
        state_region: Enum.at(parsed, 3)
      }
    end)

    content = """
    # Generated US states data
    us_states_data = #{inspect(elixir_data, pretty: true, limit: :infinity)}

    Enum.each(us_states_data, fn state ->
      SeedHelper.insert_with_id(UsState, state)
    end)
    """

    File.write!("#{@output_dir}/us_states.exs", content)
  end

  # Simple SQL value parser - handles basic cases
  defp parse_sql_values(values_string) do
    # This is a simplified parser - for production you'd want something more robust
    values_string
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn value ->
      cond do
        value == "NULL" -> nil
        String.starts_with?(value, "'") and String.ends_with?(value, "'") ->
          value |> String.slice(1..-2) |> String.replace("''", "'")
        Regex.match?(~r/^\d+$/, value) -> String.to_integer(value)
        Regex.match?(~r/^\d+\.\d+$/, value) -> Decimal.new(value)
        true -> value
      end
    end)
  end

  defp format_customer_data(parsed) do
    [customer_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax] = parsed

    %{
      customer_id: customer_id,
      company_name: company_name,
      contact_name: contact_name,
      contact_title: contact_title,
      address: address,
      city: city,
      region: region,
      postal_code: postal_code,
      country: country,
      phone: phone,
      fax: fax
    }
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> Enum.into(%{})
  end

  defp format_employee_data(parsed) do
    [employee_id, last_name, first_name, title, title_of_courtesy, birth_date, hire_date, address, city, region, postal_code, country, home_phone, extension, photo, notes, reports_to, photo_path] = parsed

    %{
      id: employee_id,
      last_name: last_name,
      first_name: first_name,
      title: title,
      title_of_courtesy: title_of_courtesy,
      birth_date: parse_date(birth_date),
      hire_date: parse_date(hire_date),
      address: address,
      city: city,
      region: region,
      postal_code: postal_code,
      country: country,
      home_phone: home_phone,
      extension: extension,
      notes: notes,
      reports_to: reports_to,
      photo_path: photo_path
    }
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> Enum.into(%{})
  end

  defp format_product_data(parsed) do
    [product_id, product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued] = parsed

    %{
      id: product_id,
      product_name: product_name,
      supplier_id: supplier_id,
      category_id: category_id,
      quantity_per_unit: quantity_per_unit,
      unit_price: if(is_number(unit_price), do: Decimal.new(to_string(unit_price)), else: unit_price),
      units_in_stock: units_in_stock,
      units_on_order: units_on_order,
      reorder_level: reorder_level,
      discontinued: discontinued == 1
    }
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> Enum.into(%{})
  end

  defp format_order_data(parsed) do
    [order_id, customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country] = parsed

    %{
      id: order_id,
      customer_id: customer_id,
      employee_id: employee_id,
      order_date: parse_date(order_date),
      required_date: parse_date(required_date),
      shipped_date: parse_date(shipped_date),
      ship_via: ship_via,
      freight: if(is_number(freight), do: Decimal.new(to_string(freight)), else: freight),
      ship_name: ship_name,
      ship_address: ship_address,
      ship_city: ship_city,
      ship_region: ship_region,
      ship_postal_code: ship_postal_code,
      ship_country: ship_country
    }
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> Enum.into(%{})
  end

  defp format_order_detail_data(parsed) do
    [order_id, product_id, unit_price, quantity, discount] = parsed

    %{
      order_id: order_id,
      product_id: product_id,
      unit_price: if(is_number(unit_price), do: Decimal.new(to_string(unit_price)), else: unit_price),
      quantity: quantity,
      discount: if(is_number(discount), do: discount, else: 0.0)
    }
  end

  defp parse_date(nil), do: nil
  defp parse_date(date_string) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      {:error, _} -> nil
    end
  end
  defp parse_date(_), do: nil
end

# Run the converter if this file is executed directly
if System.argv() == [] do
  NorthwindSQLConverter.run()
end
