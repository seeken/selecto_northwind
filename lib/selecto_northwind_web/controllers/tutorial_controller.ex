defmodule SelectoNorthwindWeb.TutorialController do
  use SelectoNorthwindWeb, :controller

  def index(conn, _params) do
    render(conn, :tutorial)
  end
end