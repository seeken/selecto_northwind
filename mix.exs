defmodule SelectoNorthwind.MixProject do
  use Mix.Project

  def project do
    [
      app: :selecto_northwind,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SelectoNorthwind.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      ecosystem_dep(:selecto, "selecto",
        ref: "0d514115afac992203b49cb027c93d5ece97abd2",
        override: true
      ),
      ecosystem_dep(:selecto_db_postgresql, "selecto_db_postgresql",
        ref: "ae310beee3ff9891b7a8ff0e82e8efec3866060d",
        override: true
      ),
      ecosystem_dep(:selecto_components, "selecto_components",
        ref: "b4ccd955f34b38eeab8093122eb640a5c5d6531b",
        override: true
      ),
      ecosystem_dep(:selecto_mix, "selecto_mix",
        ref: "68d8b520031e1a5b710cc98ef06ab13d748b8fe8",
        override: true,
        only: [:dev, :test]
      ),
      {:phoenix, "~> 1.8.0"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons, "~> 0.5"},
      {:swoosh, "~> 1.16"},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:tidewave, "~> 0.5.5", only: :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  # --- Selecto ecosystem dependency resolution -------------------------------
  # Resolves a sibling Selecto package from a local checkout when one is
  # available and from its pinned GitHub commit otherwise.
  #
  #   SELECTO_LIVE_<SIBLING>       path to a checkout, overriding discovery
  #   SELECTO_ECOSYSTEM_USE_LOCAL  1/true forces siblings, 0/false forces git
  #   SELECTO_ECOSYSTEM_GIT_URL    "ssh" fetches over SSH instead of HTTPS
  #
  # A mix.exs cannot depend on a package to compute its own deps, so this block
  # is duplicated verbatim across the Selecto repos. Keep the copies identical.
  defp ecosystem_dep(name, sibling_name, opts) do
    {ref, dep_opts} = Keyword.pop!(opts, :ref)

    case ecosystem_sibling_path(sibling_name) do
      nil -> {name, Keyword.merge(ecosystem_git_source(sibling_name, ref), dep_opts)}
      path -> {name, Keyword.put(dep_opts, :path, path)}
    end
  end

  defp ecosystem_git_source(sibling_name, ref) do
    case System.get_env("SELECTO_ECOSYSTEM_GIT_URL") do
      value when value in ["ssh", "SSH"] ->
        [git: "git@github.com:seeken/#{sibling_name}.git", ref: ref]

      _value ->
        [github: "seeken/#{sibling_name}", ref: ref]
    end
  end

  defp ecosystem_sibling_path(sibling_name) do
    case System.get_env("SELECTO_LIVE_" <> String.upcase(sibling_name)) do
      path when is_binary(path) and path != "" ->
        Path.expand(path, __DIR__)

      _value ->
        sibling = Path.expand("../#{sibling_name}", __DIR__)

        case System.get_env("SELECTO_ECOSYSTEM_USE_LOCAL") do
          value when value in ["0", "false", "FALSE", "no", "NO", "off", "OFF"] -> nil
          value when value in ["1", "true", "TRUE", "yes", "YES", "on", "ON"] -> sibling
          _value -> if File.dir?(sibling), do: sibling
        end
    end
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": [
        "tailwind.install --if-missing",
        "esbuild.install --if-missing",
        &install_asset_dependencies/1
      ],
      "assets.build": ["tailwind selecto_northwind", "esbuild selecto_northwind"],
      "assets.deploy": [
        "tailwind selecto_northwind --minify",
        "esbuild selecto_northwind --minify",
        "phx.digest"
      ],
      precommit: ["compile --warning-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end

  defp install_asset_dependencies(_args) do
    assets_dir = Path.join(__DIR__, "assets")

    if File.exists?(Path.join(assets_dir, "package.json")) do
      case Mix.shell().cmd("npm install", cd: assets_dir) do
        0 -> :ok
        status -> Mix.raise("npm install failed with exit status #{status}")
      end
    end
  end
end
