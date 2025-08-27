# Main seeds file for Northwind database
# This file uses the NorthwindSeeder module to populate the database

alias SelectoNorthwind.Seeds.NorthwindSeeder

# Check if we want to run seeds (optional environment check)
unless System.get_env("SKIP_SEEDS") == "true" do
  IO.puts("🌱 Starting Northwind database seeding...")
  
  # Seed all data: master data + fake orders
  NorthwindSeeder.seed_all(800)
  
  IO.puts("🎉 Seeding complete!")
  IO.puts("")
  IO.puts("💡 To run seeds from IEx console on Fly.io:")
  IO.puts("   NorthwindSeeder.seed_all()")
  IO.puts("   NorthwindSeeder.seed_master_data()")
  IO.puts("   NorthwindSeeder.seed_orders(1000)")
  IO.puts("   NorthwindSeeder.clear_all()")
else
  IO.puts("⏭️ Skipping seeds (SKIP_SEEDS=true)")
end