defmodule SelectoNorthwindWeb.TutorialHTML do
  @moduledoc """
  This module contains pages rendered by TutorialController.

  See the `tutorial_html` directory for all templates.
  """
  use SelectoNorthwindWeb, :html

  embed_templates "tutorial_html/*"
end