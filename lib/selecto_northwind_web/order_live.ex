defmodule SelectoNorthwindWeb.OrderLive do
  @moduledoc """
  LiveView for Order using SelectoComponents.

  ## Quick Setup (Phoenix 1.7+)

  1. Import hooks in `assets/js/app.js`:
     ```javascript
     import {hooks as selectoComponentsHooks} from "phoenix-colocated/selecto_components"
     // Add to your liveSocket hooks: { ...selectoComponentsHooks }
     ```

  2. Add to Tailwind in `assets/css/app.css`:
     ```css
     @source "../../deps/selecto_components/lib/**/*.{ex,heex}";
     ```

  3. Run `mix assets.build`

  The generated base views include `:aggregate`, `:detail`, and `:graph`.
  Extension-provided views such as `:map` or `:timeseries` are merged in
  automatically when available for the configured domain.

  That's it! The drag-and-drop query builder and charts will work automatically.
  """

  use SelectoNorthwindWeb, :live_view
  use SelectoComponents.Form

  alias SelectoComponents.Views

  @impl true
  def mount(_params, _session, socket) do
    domain = SelectoNorthwind.SelectoDomains.OrderDomain.domain()
    path = "/orders_selecto"

    selecto = Selecto.configure(domain, SelectoNorthwind.Repo)

    views = [
      Views.spec(:aggregate, Views.Aggregate, "Aggregate View", %{drill_down: :detail}),
      Views.spec(:detail, Views.Detail, "Detail View", %{}),
      Views.spec(:graph, Views.Graph, "Graph View", %{})
    ]

    state = get_initial_state(views, selecto)

    saved_views = SelectoNorthwind.SelectoDomains.OrderDomain.get_view_names(path)

    socket =
      assign(socket,
        show_view_configurator: false,
        views: views,
        my_path: path,
        path: path,
        saved_view_module: SelectoNorthwind.SelectoDomains.OrderDomain,
        saved_view_context: path,
        available_saved_views: saved_views,
        choice_source_domain: domain,
        choice_source_context: %{surface: :generated_live_view, path: path},
        choice_source_transport: :live
      )

    {:ok, assign(socket, state), layout: {SelectoNorthwindWeb.Layouts, :app}}
  end
end
