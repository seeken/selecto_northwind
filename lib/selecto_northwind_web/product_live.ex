defmodule SelectoNorthwindWeb.ProductLive do
  @moduledoc """
  LiveView for Product using SelectoComponents.

  ## Quick Setup (Phoenix 1.7+)

  1. Import hooks in `assets/js/app.js`:
     ```javascript
     import {hooks as selectoHooks} from "phoenix-colocated/selecto_components"
     // Add to your liveSocket hooks: { ...selectoHooks }
     ```

  2. Add to Tailwind in `assets/css/app.css`:
     ```css
     @source "../../vendor/selecto_components/lib/**/*.{ex,heex}";
     ```

  3. Run `mix assets.build`

  That's it! The drag-and-drop query builder and charts will work automatically.
  """

  use SelectoNorthwindWeb, :live_view
  use SelectoComponents.Form

  @impl true
  def mount(_params, _session, socket) do
    # Configure the domain and path
    domain = SelectoNorthwind.SelectoDomains.ProductDomain.domain()
    path = "/products_selecto"

    # Configure Selecto to use the main Repo connection pool
    selecto = Selecto.configure(domain, SelectoNorthwind.Repo)

    views = [
      {:aggregate, SelectoComponents.Views.Aggregate, "Aggregate View", %{drill_down: :detail}},
      {:detail, SelectoComponents.Views.Detail, "Detail View", %{}},
      {:graph, SelectoComponents.Views.Graph, "Graph View", %{}}
    ]

    state = get_initial_state(views, selecto)

    saved_views = SelectoNorthwind.SelectoDomains.ProductDomain.get_view_names(path)

    socket =
      assign(socket,
        show_view_configurator: false,
        views: views,
        my_path: path,
        saved_view_module: SelectoNorthwind.SelectoDomains.ProductDomain,
        saved_view_context: path,
        path: path,
        available_saved_views: saved_views
      )

    {:ok, assign(socket, state), layout: {SelectoNorthwindWeb.Layouts, :root}}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6">Product Explorer</h1>

      <.live_component
        module={SelectoComponents.Form}
        id="product-form"
        {assigns}
      />

      <.live_component
        module={SelectoComponents.Results}
        id="product-results"
        {assigns}
      />
    </div>
    """
  end

  @impl true
  def handle_event("toggle_show_view_configurator", _params, socket) do
    {:noreply, assign(socket, show_view_configurator: !socket.assigns.show_view_configurator)}
  end
end
