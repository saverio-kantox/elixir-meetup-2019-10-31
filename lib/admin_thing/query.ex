defmodule AdminThing.Query do
  @moduledoc """
  The behaviour and the default implementation scaffold.
  """
  @callback base_queryable() :: Ecto.Queryable.t()
  @callback repo() :: term()

  import Ecto.Query, warn: false

  @doc false
  defmacro __using__(_opts \\ []) do
    quote generated: true do
      import Ecto.Query, warn: false

      @behaviour AdminThing.Query
      @before_compile AdminThing.Query

      @spec list(params :: AdminThing.Live.params()) :: [struct()]
      @doc "Lists all the records, filtered and paginated according to the params passed."
      def list(params \\ %{}) do
        query(params)
        |> repo.all()
      end

      @spec get_page_count(params :: AdminThing.Live.params()) :: non_neg_integer()
      @doc "Returns the number of pages."
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

      @spec query(params :: AdminThing.Live.params()) :: [struct()]
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
  defmacro __before_compile__(_env) do
    quote do
      defp do_sort(queryable, {key, direction}) do
        from u in queryable, order_by: ^[{direction, key}]
      end

      defp do_filter(queryable, {key, value}) do
        from u in queryable, where: ^[{key, value}]
      end
    end
  end

  @spec paginate(queryable :: any(), params :: nil | AdminThing.Live.params()) :: any()
  @doc "Performs an actual pagination."
  def paginate(queryable, nil), do: queryable

  def paginate(queryable, %{} = param) do
    page_size = Map.get(param, "size", 5)
    page_number = Map.get(param, "number", 1)
    from u in queryable, limit: ^page_size, offset: ^((page_number - 1) * page_size)
  end

  @spec sort(
          queryable :: any(),
          params :: nil | AdminThing.Live.params(),
          cb :: (any(), {atom(), atom()} -> any())
        ) :: any()
  @doc "Performs an actual sorting."
  def sort(queryable, nil, _), do: queryable
  def sort(queryable, "", _), do: queryable

  def sort(queryable, "-" <> key, cb),
    do: cb.(queryable, {String.to_existing_atom(key), :desc})

  def sort(queryable, key, cb), do: cb.(queryable, {String.to_existing_atom(key), :asc})

  @spec filter(
          queryable :: any(),
          params :: nil | AdminThing.Live.params(),
          cb :: (any(), {atom(), atom()} -> any())
        ) :: any()
  @doc "Performs an actual filtering."
  def filter(queryable, nil, _), do: queryable

  def filter(queryable, %{} = filters, cb) do
    for {k, v} <- filters, reduce: queryable do
      queryable -> cb.(queryable, {String.to_existing_atom(k), v})
    end
  end
end
