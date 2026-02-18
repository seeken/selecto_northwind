defmodule SelectoNorthwindWeb.TutorialController do
  use SelectoNorthwindWeb, :controller

  def index(conn, _params) do
    render(conn, :tutorial)
  end

  def postgrex_tutorial(conn, _params) do
    render(conn, :postgrex_tutorial)
  end
end
