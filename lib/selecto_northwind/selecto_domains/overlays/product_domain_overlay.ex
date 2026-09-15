# lib/selecto_northwind/selecto_domains/overlays/product_domain_overlay.ex
defmodule SelectoNorthwind.SelectoDomains.Overlays.ProductDomainOverlay do
  use Selecto.Config.OverlayDSL

  defpopup :product_overview do
    name("Product Overview")
    description("Open the selected product in the built-in detail modal.")
    required_fields([:id, :product_name, :unit_price])

    payload(%{
      title: ~S(Product #{{id}} - {{product_name}}),
      size: :xl,
      navigation_enabled: true
    })
  end
end
