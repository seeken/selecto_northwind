defmodule SelectoNorthwindWeb.PageController do
  use SelectoNorthwindWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
