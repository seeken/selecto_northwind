# Emits observations only. Expected results and verdicts stay in selecto-protocol.
[input_path, output_path] = System.argv()
fixture = input_path |> File.read!() |> Jason.decode!()
alias SelectoNorthwind.Repo
alias Selecto.Expr, as: X

schema = fn table, fields ->
  %{
    source_table: table,
    primary_key: :id,
    fields: Keyword.keys(fields),
    columns: Map.new(fields, fn {key, type} -> {key, %{type: type}} end),
    redact_fields: [],
    associations: %{}
  }
end

domain = %{
  name: "Canned fixture",
  source:
    schema.("canned_products",
      id: :integer,
      name: :string,
      category: :string,
      brand: :string,
      price: :integer,
      visible: :integer
    )
    |> Map.put(:associations, %{
      tags: %{queryable: :tags, field: :tags, owner_key: :id, related_key: :product_id}
    }),
  schemas: %{tags: schema.("canned_tags", id: :integer, product_id: :integer, label: :string)},
  joins: %{tags: %{type: :left, cardinality: :many}}
}

base = Selecto.configure(domain, Repo, adapter: SelectoDBPostgreSQL.Adapter)
definition = fixture["page"]

views =
  Enum.map(definition["views"], fn view ->
    selectors =
      view["fields"] ++
        if(view["count_distinct"],
          do: [X.as(X.count_distinct(view["count_distinct"]), "items")],
          else: []
        )

    %{
      id: view["id"],
      kind: if(view["kind"] == "detail", do: :detail, else: :aggregate),
      query: base |> Selecto.select(selectors) |> Selecto.group_by(view["groups"])
    }
  end)

controls =
  Enum.map(definition["controls"], fn control ->
    kind = %{"facet" => :facet, "range" => :range, "text" => :text}[control["kind"]]

    options =
      if control["options"],
        do: Enum.map(control["options"], &%{value: &1["value"], label: &1["label"]}),
        else: nil

    %{
      id: control["id"],
      field: control["field"],
      kind: kind,
      limit: Map.get(control, "limit", 30),
      searchable: Map.get(control, "searchable", false),
      options: options
    }
  end)

dataset =
  Enum.reduce(definition["fixed_filters"], base, fn [field, value], query ->
    Selecto.filter(query, X.eq(field, value))
  end)

page =
  Selecto.CannedPage.new!(dataset,
    id: definition["id"],
    views: views,
    controls: controls,
    initial_state: definition["initial_state"]
  )

{:ok, observations} =
  Repo.transaction(fn ->
    Repo.query!(
      "CREATE TEMP TABLE canned_products (id integer primary key, name text, category text, brand text, price integer, visible integer) ON COMMIT DROP"
    )

    Repo.query!(
      "CREATE TEMP TABLE canned_tags (id integer primary key, product_id integer, label text) ON COMMIT DROP"
    )

    Enum.each(
      fixture["rows"],
      &Repo.query!("INSERT INTO canned_products VALUES ($1,$2,$3,$4,$5,$6)", &1)
    )

    Enum.each(fixture["tags"], &Repo.query!("INSERT INTO canned_tags VALUES ($1,$2,$3)", &1))

    Enum.map(fixture["cases"], fn item ->
      authorized =
        if item["scope_max_id"],
          do: Selecto.filter(base, X.lte("id", item["scope_max_id"])),
          else: base

      case Selecto.CannedPage.run(page, authorized, item["state"]) do
        {:ok, output} ->
          Map.take(output, [:total, :rows, :facets, :has_more])
          |> Map.merge(%{id: item["id"], ok: true})

        {:error, _} ->
          %{id: item["id"], ok: false}
      end
    end)
  end)

File.write!(output_path, Jason.encode!(observations, pretty: true))
