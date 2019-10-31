defmodule AdminThing.Query do
  @callback base_queryable() :: Ecto.Queryable.t()
  @callback repo() :: term()

  import Ecto.Query, warn: false

  defmacro __using__(_opts \\ []) do
    quote do
      import Ecto.Query, warn: false

      @behavior AdminThing.Query
      @before_compile AdminThing.Query

      def list(params \\ %{}) do
        query(params)
        |> repo.all()
      end

      def get_page_count(params \\ %{}) do
        query(params)
        |> exclude(:limit)
        |> exclude(:offset)
        |> exclude(:order_by)
        |> select([u], count(u.id, :distinct))
        |> repo.one()
        |> case do
          0 -> 1
          n -> Integer.floor_div(n - 1, get_in(params, ~w[page size])) + 1
        end
      end

      defp query(params) do
        base_queryable()
        |> AdminThing.Query.paginate(Map.get(params, "page"))
        |> AdminThing.Query.sort(Map.get(params, "sort"), &do_sort/2)
        |> AdminThing.Query.filter(Map.get(params, "filter"), &do_filter/2)
      end
    end
  end

  @doc """
  Add fallback implementations for sort and filter.
  """
  defmacro __before_compile__(_) do
    quote do
      defp do_sort(queryable, {key, direction}) do
        from u in queryable, order_by: ^[{direction, key}]
      end

      defp do_filter(queryable, {key, value}) do
        from u in queryable, where: ^[{key, value}]
      end
    end
  end

  def paginate(queryable, nil), do: queryable

  def paginate(queryable, %{} = param) do
    page_size = Map.get(param, "size", 5)
    page_number = Map.get(param, "number", 1)
    from u in queryable, limit: ^page_size, offset: ^((page_number - 1) * page_size)
  end

  def sort(queryable, nil, _), do: queryable
  def sort(queryable, "", _), do: queryable

  def sort(queryable, "-" <> key, cb),
    do: cb.(queryable, {String.to_existing_atom(key), :desc})

  def sort(queryable, key, cb), do: cb.(queryable, {String.to_existing_atom(key), :asc})

  def filter(queryable, nil, _), do: queryable

  def filter(queryable, %{} = filters, cb) do
    for {k, v} <- filters, reduce: queryable do
      queryable -> cb.(queryable, {String.to_existing_atom(k), v})
    end
  end
end
