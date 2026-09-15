defmodule SelectoNorthwindWeb.LiveDashboard.SelectoPage do
  @moduledoc """
  LiveDashboard page for Selecto query metrics and performance monitoring.
  """

  use Phoenix.LiveDashboard.PageBuilder

  @impl true
  def menu_link(_, _) do
    {:ok, "Selecto"}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card">
      <div class="card-body">
        <h2 class="card-title">Selecto</h2>
        <p>Selecto telemetry metrics are registered for this application.</p>
      </div>
    </div>
    """
  end
end
