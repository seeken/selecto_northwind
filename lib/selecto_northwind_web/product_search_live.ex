defmodule SelectoNorthwindWeb.ProductSearchLive do
  use SelectoNorthwindWeb, :live_view
  alias SelectoNorthwind.ProductSearch

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page: ProductSearch.page(),
       authorize: &ProductSearch.authorize/0,
       page_params: %{},
       page_path: "/pages/products",
       layouts: %{
         "detail" => [
           %{
             kind: :link,
             field: "id",
             label: "Product",
             text: "Open",
             url_prefix: "/pages/products/"
           },
           %{kind: :field, field: "product_name", label: "Product name"},
           %{kind: :field, field: "category_name", label: "Category"},
           %{kind: :field, field: "company_name", label: "Supplier"},
           %{kind: :field, field: "unit_price", label: "Unit price"},
           %{kind: :field, field: "units_in_stock", label: "Stock"}
         ]
       }
     ), layout: false}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    state =
      case Map.get(params, "state") do
        nil ->
          %{}

        encoded when is_binary(encoded) and byte_size(encoded) <= 32_768 ->
          case Jason.decode(encoded) do
            {:ok, state} when is_map(state) -> state
            _ -> %{"invalid" => true}
          end

        _ ->
          %{"invalid" => true}
      end

    {authorize, path} =
      case Map.get(params, "id") do
        nil ->
          {&ProductSearch.authorize/0, "/pages/products"}

        id ->
          {fn ->
             unless Regex.match?(~r/\A[1-9][0-9]*\z/, id),
               do: raise(ArgumentError, "invalid product")

             Selecto.filter(
               ProductSearch.authorize(),
               Selecto.Expr.eq("id", String.to_integer(id))
             )
           end, "/pages/products/" <> URI.encode(id)}
      end

    {:noreply, assign(socket, page_params: state, authorize: authorize, page_path: path)}
  end

  @impl true
  def handle_info({:selecto_canned_page_state, "products", state}, socket) do
    {:noreply,
     push_patch(socket,
       to: socket.assigns.page_path <> "?" <> URI.encode_query(%{state: Jason.encode!(state)})
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.live_component
        module={SelectoViews.CannedPage}
        id="products"
        title="Product search"
        page={@page}
        layouts={@layouts}
        authorize={@authorize}
        params={@page_params}
        private={false}
      />
    </Layouts.app>
    """
  end
end
