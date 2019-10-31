defmodule AdminThing.Live do
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

  def prepare_params(params) do
    params
    |> Map.put_new("page", %{})
    |> Map.update("page", nil, &Map.update(&1, "number", 1, fn x -> String.to_integer(x) end))
    |> Map.update("page", nil, &Map.update(&1, "size", 5, fn x -> String.to_integer(x) end))
  end

  def load_data(socket, params, query_module, opts \\ []) do
    params = prepare_params(params)
    records = query_module.list(params)
    total_pages = query_module.get_page_count(params)

    socket
    |> Phoenix.LiveView.assign(query_params: params, total_pages: total_pages)
    |> Phoenix.LiveView.assign(Keyword.get(opts, :into, :records), records)
  end
end
