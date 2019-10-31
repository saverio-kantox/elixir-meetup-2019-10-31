defmodule AdminThing.Live do
  @moduledoc """
  Use this module to ease producing of filtered and/or paginated live views.
  """
  @doc false
  defmacro __using__(opts \\ []) do
    routes = Keyword.fetch!(opts, :routes)

    quote do
      def handle_event("filter", form_content, socket) do
        old_query_params = socket.assigns[:query_params]

        filters =
          for {k, v} <- form_content["filter"], k != "_target", v != "", into: %{}, do: {k, v}

        new_query_params =
          old_query_params
          |> Map.put("filter", filters)
          |> Map.put_new("page", %{})
          |> put_in(~w[page number], 1)

        {:noreply,
         live_redirect(socket,
           to: unquote(routes).live_path(socket, __MODULE__, new_query_params)
         )}
      end
    end
  end

  @typedoc "The map representing the query params."
  @type params :: %{binary() => any()}

  @spec prepare_params(params :: params()) :: params()
  @doc "Updates params by putting the default values into, if needed."
  def prepare_params(params) do
    params
    |> Map.put_new("page", %{})
    |> update_in(~w[page number], fn
      nil -> 1
      n -> String.to_integer(n)
    end)
    |> update_in(~w[page size], fn
      nil -> 5
      n -> String.to_integer(n)
    end)
  end

  @spec load_data(
          socket :: any(),
          params :: params(),
          query_module :: module(),
          opts :: keyword()
        ) :: any()
  @doc "Loads the data into the socket."
  def load_data(socket, params, query_module, opts \\ []) do
    params = prepare_params(params)
    records = query_module.list(params)
    total_pages = query_module.get_page_count(params)

    socket
    |> Phoenix.LiveView.assign(query_params: params, total_pages: total_pages)
    |> Phoenix.LiveView.assign(Keyword.get(opts, :into, :records), records)
  end
end
