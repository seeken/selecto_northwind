defmodule SelectoNorthwind.Seeds.NorthwindSeeder do
  @moduledoc """
  Northwind database seeder module that can be run from IEx console or programmatically.

  Usage:
    # Seed all data
    NorthwindSeeder.seed_all()

    # Seed only master data
    NorthwindSeeder.seed_master_data()

    # Generate fake orders
    NorthwindSeeder.seed_orders(800)

    # Clear all data
    NorthwindSeeder.clear_all()
  """

  alias SelectoNorthwind.Repo
  alias SelectoNorthwind.Catalog.{Category, Supplier, Product, Tag, ProductTag}
  alias SelectoNorthwind.Sales.{Customer, Order, OrderDetail, Shipper, CustomerDemographic, CustomerCustomerDemo}
  alias SelectoNorthwind.Hr.{Employee, EmployeeTerritory}
  alias SelectoNorthwind.Geography.{Region, Territory, UsState}

  import Ecto.Query
  require Logger

  @doc """
  Seeds all Northwind data: master data + 800 fake orders
  """
  def seed_all(num_orders \\ 800) do
    Logger.info("🌱 Starting complete Northwind database seeding...")

    Repo.transaction(fn ->
      clear_all()
      seed_master_data()
      seed_orders(num_orders)
    end)

    Logger.info("🎉 Complete seeding finished!")
  end

  @doc """
  Seeds only the master data (categories, customers, employees, etc.)
  """
  def seed_master_data do
    Logger.info("📊 Seeding Northwind master data...")

    # Seed without top-level transaction to avoid issues
    seed_categories()
    seed_customers()
    seed_employees()
    seed_suppliers()
    seed_products()
    seed_tags()
    seed_product_tags()
    seed_shippers()
    seed_regions()
    seed_territories()
    seed_employee_territories()

    Logger.info("✅ Master data seeding complete!")
    print_master_data_stats()
  end

  @doc """
  Generates fake orders and order details
  """
  def seed_orders(num_orders \\ 800) do
    Logger.info("🛍️ Generating #{num_orders} fake orders...")

    # Clear existing orders first
    Repo.delete_all(OrderDetail)
    Repo.delete_all(Order)

    # Get reference data
    customers = get_customer_ids()
    employees = get_employee_ids()
    products = get_products_with_prices()

    if Enum.empty?(customers) or Enum.empty?(employees) or map_size(products) == 0 do
      Logger.error("❌ Master data not found. Please run seed_master_data() first.")
      {:error, :missing_master_data}
    else
      # Seed random number generator for consistent results
      :rand.seed(:exsss, {1, 2, 3})

      orders_data = generate_orders(num_orders, customers, employees, products)
      inserted_orders = insert_orders(orders_data)

      order_details_data = generate_order_details(inserted_orders, products)
      insert_order_details(order_details_data)

      Logger.info("✅ Orders seeding complete!")
      print_orders_stats(inserted_orders, order_details_data)

      {:ok, %{orders: length(orders_data), order_details: length(order_details_data)}}
    end
  end

  @doc """
  Clears all data from the database
  """
  def clear_all do
    Logger.info("🧹 Clearing all Northwind data...")

    Repo.delete_all(OrderDetail)
    Repo.delete_all(Order)
    Repo.delete_all(CustomerCustomerDemo)
    Repo.delete_all(EmployeeTerritory)
    Repo.delete_all(Territory)
    Repo.delete_all(Region)
    Repo.delete_all(ProductTag)
    Repo.delete_all(Tag)
    Repo.delete_all(Product)
    Repo.delete_all(Category)
    Repo.delete_all(Supplier)
    Repo.delete_all(Customer)
    Repo.delete_all(Employee)
    Repo.delete_all(Shipper)
    Repo.delete_all(CustomerDemographic)
    Repo.delete_all(UsState)

    # Reset sequences to start from 1 again
    reset_sequences()

    Logger.info("✅ Database cleared and sequences reset!")
  end

  @doc """
  Resets database sequences to start from 1
  """
  def reset_sequences do
    Logger.info("🔄 Resetting database sequences...")

    # Get all sequences in the database
    sequences_query = """
    SELECT sequence_name
    FROM information_schema.sequences
    WHERE sequence_schema = 'public'
    """

    case Ecto.Adapters.SQL.query(Repo, sequences_query, []) do
      {:ok, %Postgrex.Result{rows: sequences}} ->
        Enum.each(sequences, fn [sequence_name] ->
          sql = "ALTER SEQUENCE #{sequence_name} RESTART WITH 1"
          case Ecto.Adapters.SQL.query(Repo, sql, []) do
            {:ok, _} -> Logger.debug("Reset sequence: #{sequence_name}")
            {:error, error} -> Logger.warning("Failed to reset sequence #{sequence_name}: #{inspect(error)}")
          end
        end)
        Logger.info("✅ Sequences reset!")
      {:error, error} ->
        Logger.error("Failed to query sequences: #{inspect(error)}")
    end
  end

  # Private functions for seeding master data
  
  # Helper function to generate a deterministic but scattered timestamp
  defp generate_scattered_timestamp(base_id, base_time \\ nil) do
    base = base_time || DateTime.utc_now()
    
    # Use the ID as seed for deterministic but varied offsets
    # This ensures the same ID always gets the same timestamp
    seed_hash = :erlang.phash2(base_id, 1000000)
    
    # Generate offsets within the past 6 months (roughly 180 days)
    day_offset = rem(seed_hash, 180) + 1  # 1 to 180 days ago
    hour_offset = rem(div(seed_hash, 180), 24)  # 0 to 23 hours
    minute_offset = rem(div(seed_hash, 4320), 60)  # 0 to 59 minutes
    
    scattered_datetime = base
                        |> DateTime.add(-day_offset * 24 * 60 * 60, :second)  # Subtract days
                        |> DateTime.add(-hour_offset * 60 * 60, :second)      # Subtract hours
                        |> DateTime.add(-minute_offset * 60, :second)         # Subtract minutes
    
    # Convert to naive datetime for Ecto and truncate microseconds
    scattered_datetime
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end

  defp seed_categories do
    Logger.info("📊 Seeding Categories...")

    SelectoNorthwind.Seeds.NorthwindData.categories_data()
    |> Enum.each(fn category ->
      insert_with_id(Category, category)
    end)
  end

  defp seed_customers do
    Logger.info("👥 Seeding Customers...")

    SelectoNorthwind.Seeds.NorthwindData.customers_data()
    |> Enum.each(fn customer ->
      # Use a hash of the customer_id string for deterministic timestamps
      id_hash = :erlang.phash2(customer.customer_id, 1000000)
      scattered_time = generate_scattered_timestamp(id_hash)
      
      customer_data_with_timestamps = customer
                                    |> Map.put(:inserted_at, scattered_time)
                                    |> Map.put(:updated_at, scattered_time)
      
      Repo.insert!(Customer.changeset(%Customer{}, customer_data_with_timestamps))
    end)
  end

  defp seed_employees do
    Logger.info("👨‍💼 Seeding Employees...")

    # Sort employees to insert managers first (those with nil reports_to)
    employees_data = SelectoNorthwind.Seeds.NorthwindData.employees_data()
    |> Enum.sort_by(fn emp ->
      case Map.get(emp, :reports_to) do
        nil -> 0  # Managers first
        _ -> 1    # Employees second
      end
    end)

    # Step 1: Insert all employees without reports_to to avoid foreign key issues
    employee_mappings = Enum.map(employees_data, fn employee_data ->
      # Remove reports_to from the data for initial insert
      employee_without_reports_to = Map.delete(employee_data, :reports_to)
      
      # Add scattered timestamps
      scattered_time = generate_scattered_timestamp(employee_data.id)
      employee_with_timestamps = employee_without_reports_to
                               |> Map.put(:inserted_at, scattered_time)
                               |> Map.put(:updated_at, scattered_time)
      
      # Insert the employee and get the new ID
      changeset = Employee.changeset(%Employee{}, employee_with_timestamps)
      changeset = Ecto.Changeset.put_change(changeset, :id, employee_data.id)
      inserted_employee = Repo.insert!(changeset)

      # Return mapping of original ID to new database ID
      {employee_data.id, inserted_employee.id}
    end) |> Enum.into(%{})

    # Step 2: Update reports_to references using the mapping
    Enum.each(employees_data, fn employee_data ->
      case Map.get(employee_data, :reports_to) do
        nil ->
          # Manager, no update needed
          :ok
        original_manager_id ->
          # Employee with manager - update reports_to to use new database ID
          new_manager_id = Map.get(employee_mappings, original_manager_id)
          new_employee_id = Map.get(employee_mappings, employee_data.id)

          if new_manager_id && new_employee_id do
            Repo.update_all(
              from(e in Employee, where: e.id == ^new_employee_id),
              set: [reports_to: new_manager_id]
            )
          end
      end
    end)
  end

  defp seed_suppliers do
    Logger.info("🏪 Seeding Suppliers...")

    SelectoNorthwind.Seeds.NorthwindData.suppliers_data()
    |> Enum.each(fn supplier ->
      Logger.debug("Inserting supplier: #{supplier.company_name} with ID: #{supplier.id}")
      inserted = insert_with_id(Supplier, supplier)
      Logger.debug("Successfully inserted supplier: #{inserted.company_name} with database ID: #{inserted.id}")
    end)

    # Verify suppliers were inserted
    supplier_count = Repo.aggregate(Supplier, :count)
    Logger.info("✅ Inserted #{supplier_count} suppliers")

    # Check if supplier ID 1 exists
    supplier_1 = Repo.get(Supplier, 1)
    if supplier_1 do
      Logger.info("✅ Supplier ID 1 exists: #{supplier_1.company_name}")
    else
      Logger.error("❌ Supplier ID 1 does not exist!")
    end
  end

  defp seed_products do
    Logger.info("📦 Seeding Products...")

    SelectoNorthwind.Seeds.NorthwindData.products_data()
    |> Enum.each(fn product ->
      Logger.debug("Inserting product: #{product.product_name} with supplier_id: #{product.supplier_id}")
      insert_with_id(Product, product)
    end)
  end

  defp seed_tags do
    Logger.info("🏷️ Seeding Tags...")

    tags_data = [
      %{name: "Organic", description: "Certified organic products"},
      %{name: "Kosher", description: "Kosher certified products"},
      %{name: "Gluten-Free", description: "Products without gluten"},
      %{name: "Vegan", description: "Products containing no animal ingredients"},
      %{name: "Fair Trade", description: "Fair trade certified products"},
      %{name: "Non-GMO", description: "Products without genetically modified ingredients"},
      %{name: "Dairy-Free", description: "Products without dairy ingredients"},
      %{name: "Sugar-Free", description: "Products without added sugar"},
      %{name: "Local", description: "Locally sourced products"},
      %{name: "Sustainable", description: "Sustainably produced products"}
    ]

    tags_data
    |> Enum.each(fn tag ->
      %Tag{}
      |> Tag.changeset(tag)
      |> Repo.insert!()
    end)
  end

  defp seed_product_tags do
    Logger.info("🔗 Seeding Product Tags...")

    # Get tags and products
    tags = Repo.all(Tag) |> Enum.into(%{}, &{&1.name, &1})
    products = Repo.all(Product)
    total_products = length(products)

    # Seed random number generator for consistent results
    :rand.seed(:exsss, {1, 2, 3})

    # We want:
    # - Average of 1 tag per product
    # - At least half have no tags
    # - Some products have up to 4 tags

    # Calculate how many products should have tags (roughly half)
    products_with_tags = div(total_products, 2)

    # Define tag distribution for products that will have tags
    # This creates an average of ~2 tags per tagged product
    # which gives us overall average of 1 tag per product
    tag_counts = [
      {1, 40},  # 40% get 1 tag
      {2, 35},  # 35% get 2 tags
      {3, 15},  # 15% get 3 tags
      {4, 10}   # 10% get 4 tags
    ]

    # Shuffle and select products that will get tags
    selected_products = Enum.shuffle(products) |> Enum.take(products_with_tags)

    # Assign tags to selected products based on distribution
    {_remaining_products, total_tagged} = Enum.reduce(tag_counts, {selected_products, 0}, fn {num_tags, percentage}, {remaining, tagged_count} ->
      # Calculate how many products should get this many tags
      count = round(products_with_tags * percentage / 100)
      products_for_this_count = Enum.take(remaining, count)

      # Assign tags to these products
      Enum.each(products_for_this_count, fn product ->
        # Select random tags
        random_tags = Enum.take_random(Map.values(tags), num_tags)

        Enum.each(random_tags, fn tag ->
          %ProductTag{}
          |> ProductTag.changeset(%{product_id: product.id, tag_id: tag.id})
          |> Repo.insert!()
        end)
      end)

      {Enum.drop(remaining, count), tagged_count + length(products_for_this_count)}
    end)

    # Count total tag assignments
    total_tag_assignments = Repo.aggregate(ProductTag, :count)
    avg_tags = if total_products > 0, do: Float.round(total_tag_assignments / total_products, 2), else: 0

    Logger.info("✅ Tagged #{total_tagged} products with #{total_tag_assignments} total tag assignments (avg: #{avg_tags} tags/product)")
  end

  defp seed_shippers do
    Logger.info("🚚 Seeding Shippers...")

    SelectoNorthwind.Seeds.NorthwindData.shippers_data()
    |> Enum.each(fn shipper ->
      insert_with_id(Shipper, shipper)
    end)
  end

  defp seed_regions do
    Logger.info("🌍 Seeding Regions...")

    SelectoNorthwind.Seeds.NorthwindData.regions_data()
    |> Enum.each(fn region ->
      insert_with_id(Region, region)
    end)
  end

  defp seed_territories do
    Logger.info("🗺️ Seeding Territories...")

    SelectoNorthwind.Seeds.NorthwindData.territories_data()
    |> Enum.each(fn territory ->
      # Use a hash of the territory_id string for deterministic timestamps
      id_hash = :erlang.phash2(territory.territory_id, 1000000)
      scattered_time = generate_scattered_timestamp(id_hash)
      
      territory_data_with_timestamps = territory
                                     |> Map.put(:inserted_at, scattered_time)
                                     |> Map.put(:updated_at, scattered_time)
      
      Repo.insert!(Territory.changeset(%Territory{}, territory_data_with_timestamps))
    end)
  end

  defp seed_employee_territories do
    Logger.info("🏢 Seeding Employee Territories...")

    SelectoNorthwind.Seeds.NorthwindData.employee_territories_data()
    |> Enum.each(fn et ->
      # Use a combination of employee_id and territory_id for unique timestamps
      id_hash = :erlang.phash2({et.employee_id, et.territory_id}, 1000000)
      scattered_time = generate_scattered_timestamp(id_hash)
      
      et_data_with_timestamps = et
                              |> Map.put(:inserted_at, scattered_time)
                              |> Map.put(:updated_at, scattered_time)
      
      Repo.insert!(EmployeeTerritory.changeset(%EmployeeTerritory{}, et_data_with_timestamps))
    end)
  end

  # Helper function to insert with explicit ID and scattered timestamps
  defp insert_with_id(schema_module, changeset_data) do
    base_time = DateTime.utc_now()
    scattered_time = generate_scattered_timestamp(changeset_data.id, base_time)
    
    # Create changeset and explicitly set the ID and timestamps
    changeset = schema_module.changeset(struct(schema_module), changeset_data)
    changeset = changeset
                |> Ecto.Changeset.put_change(:id, changeset_data.id)
                |> Ecto.Changeset.put_change(:inserted_at, scattered_time)
                |> Ecto.Changeset.put_change(:updated_at, scattered_time)
                
    Repo.insert!(changeset)
  end

  # Order generation functions

  defp generate_orders(num_orders, customers, employees, products) when is_list(customers) and is_list(employees) and is_map(products) do
    # Calculate date ranges for the past 3 months
    today = Date.utc_today()
    three_months_ago = Date.add(today, -90)
    
    Enum.map(1..num_orders, fn order_num ->
      order_id = 20000 + order_num

      customer_id = Enum.random(customers)
      employee_id = Enum.random(employees)
      shipper_id = :rand.uniform(3)

      # Generate order date within past 3 months
      order_date = random_date_in_range(three_months_ago, today)
      required_date = Date.add(order_date, :rand.uniform(28) + 7)

      shipped_date = if :rand.uniform(100) <= 85 do
        ship_days = :rand.uniform(14) + 1
        shipped = add_business_days(order_date, ship_days)
        if Date.compare(shipped, Date.utc_today()) == :lt, do: shipped, else: nil
      else
        nil
      end

      freight = random_freight()
      customer = Repo.get!(Customer, customer_id)

      %{
        id: order_id,
        customer_id: customer_id,
        employee_id: employee_id,
        order_date: order_date,
        required_date: required_date,
        shipped_date: shipped_date,
        ship_via: shipper_id,
        freight: freight,
        ship_name: customer.company_name,
        ship_address: customer.address,
        ship_city: customer.city,
        ship_region: customer.region,
        ship_postal_code: customer.postal_code,
        ship_country: customer.country
      }
    end)
  end

  defp generate_order_details(inserted_orders, products) do
    Enum.flat_map(inserted_orders, fn order ->
      num_items = items_per_order()
      product_ids = Map.keys(products) |> Enum.take_random(num_items)

      Enum.map(product_ids, fn product_id ->
        unit_price = products[product_id]
        quantity = random_quantity()
        discount = random_discount()

        %{
          order_id: order.id,
          product_id: product_id,
          unit_price: unit_price,
          quantity: quantity,
          discount: discount
        }
      end)
    end)
  end

  defp insert_orders(orders_data) do
    Enum.map(orders_data, fn order_data ->
      # Generate scattered timestamp based on order ID
      # Use the order_date as a base to keep timestamps somewhat realistic
      base_datetime = DateTime.new!(order_data.order_date, ~T[09:00:00])
      
      # Add some variation within a few hours of the order date
      id_hash = :erlang.phash2(order_data.id, 1000)
      hour_variation = rem(id_hash, 12)  # 0 to 12 hours
      minute_variation = rem(div(id_hash, 12), 60)  # 0 to 59 minutes
      
      scattered_time = base_datetime
                      |> DateTime.add(hour_variation * 60 * 60, :second)
                      |> DateTime.add(minute_variation * 60, :second)
                      |> DateTime.to_naive()
                      |> NaiveDateTime.truncate(:second)
      
      order_data_with_timestamps = order_data
                                 |> Map.put(:inserted_at, scattered_time)
                                 |> Map.put(:updated_at, scattered_time)
      
      Repo.insert!(Order.changeset(%Order{}, order_data_with_timestamps))
    end)
  end

  defp insert_order_details(order_details_data) do
    Enum.each(order_details_data, fn detail_data ->
      # Generate timestamp based on order_id and product_id combination
      id_hash = :erlang.phash2({detail_data.order_id, detail_data.product_id}, 1000)
      
      # Get the order's timestamp as base
      order = Repo.get!(Order, detail_data.order_id)
      base_time = order.inserted_at
      
      # Add small variation (within a few minutes of order creation)
      minute_variation = rem(id_hash, 30)  # 0 to 30 minutes after order
      
      scattered_time = NaiveDateTime.add(base_time, minute_variation * 60, :second)
      
      detail_data_with_timestamps = detail_data
                                  |> Map.put(:inserted_at, scattered_time)
                                  |> Map.put(:updated_at, scattered_time)
      
      Repo.insert!(OrderDetail.changeset(%OrderDetail{}, detail_data_with_timestamps))
    end)
  end

  # Utility functions for order generation

  defp get_customer_ids do
    Repo.all(from c in Customer, select: c.customer_id) |> Enum.sort()
  end

  defp get_employee_ids do
    Repo.all(from e in Employee, select: e.id) |> Enum.sort()
  end

  defp get_products_with_prices do
    Repo.all(from p in Product, select: {p.id, p.unit_price}) |> Enum.into(%{})
  end

  defp random_date_in_range(start_date, end_date) do
    start_days = Date.diff(start_date, ~D[2020-01-01])
    end_days = Date.diff(end_date, ~D[2020-01-01])
    random_days = :rand.uniform(end_days - start_days) + start_days
    Date.add(~D[2020-01-01], random_days)
  end

  defp add_business_days(date, days) do
    Enum.reduce(1..days, date, fn _, acc_date ->
      next_date = Date.add(acc_date, 1)
      case Date.day_of_week(next_date) do
        day when day in [6, 7] -> Date.add(next_date, 8 - day)
        _ -> next_date
      end
    end)
  end

  defp random_freight do
    case :rand.uniform(100) do
      n when n <= 40 -> Decimal.new(:rand.uniform(50) + 5)
      n when n <= 70 -> Decimal.new(:rand.uniform(100) + 50)
      n when n <= 90 -> Decimal.new(:rand.uniform(200) + 100)
      _ -> Decimal.new(:rand.uniform(500) + 200)
    end
  end

  defp random_discount do
    case :rand.uniform(100) do
      n when n <= 60 -> 0.0
      n when n <= 80 -> 0.05
      n when n <= 90 -> 0.10
      n when n <= 95 -> 0.15
      _ -> 0.20
    end
  end

  defp random_quantity do
    case :rand.uniform(100) do
      n when n <= 50 -> :rand.uniform(10)
      n when n <= 80 -> :rand.uniform(25) + 10
      n when n <= 95 -> :rand.uniform(50) + 25
      _ -> :rand.uniform(100) + 50
    end
  end

  defp items_per_order do
    case :rand.uniform(100) do
      n when n <= 30 -> 1
      n when n <= 60 -> 2
      n when n <= 80 -> 3
      n when n <= 90 -> 4
      n when n <= 95 -> 5
      _ -> :rand.uniform(5) + 5
    end
  end

  # Statistics and reporting

  defp print_master_data_stats do
    Logger.info("📊 Master Data Summary:")
    Logger.info("  - #{Repo.aggregate(Category, :count)} Categories")
    Logger.info("  - #{Repo.aggregate(Customer, :count)} Customers")
    Logger.info("  - #{Repo.aggregate(Employee, :count)} Employees")
    Logger.info("  - #{Repo.aggregate(Supplier, :count)} Suppliers")
    Logger.info("  - #{Repo.aggregate(Product, :count)} Products")
    Logger.info("  - #{Repo.aggregate(Shipper, :count)} Shippers")
    Logger.info("  - #{Repo.aggregate(Region, :count)} Regions")
    Logger.info("  - #{Repo.aggregate(Territory, :count)} Territories")
  end

  defp print_orders_stats(orders_data, order_details_data) do
    total_orders = length(orders_data)
    total_details = length(order_details_data)
    avg_items_per_order = Float.round(total_details / total_orders, 2)

    shipped_orders = Enum.count(orders_data, & &1.shipped_date)
    shipped_percentage = Float.round(shipped_orders / total_orders * 100, 1)

    total_revenue = order_details_data
    |> Enum.map(fn detail ->
      price = Decimal.to_float(detail.unit_price)
      quantity = detail.quantity
      discount = detail.discount
      price * quantity * (1 - discount)
    end)
    |> Enum.sum()
    |> Float.round(2)

    Logger.info("📊 Orders Summary:")
    Logger.info("  - Total Orders: #{total_orders}")
    Logger.info("  - Total Order Details: #{total_details}")
    Logger.info("  - Average Items per Order: #{avg_items_per_order}")
    Logger.info("  - Shipped Orders: #{shipped_orders} (#{shipped_percentage}%)")
    Logger.info("  - Total Revenue: $#{:erlang.float_to_binary(total_revenue, decimals: 2)}")
  end

  # Data is stored in SelectoNorthwind.Seeds.NorthwindData module
end
