defmodule AdminThing.View do
  @moduledoc "The scaffold implementation of the `Phoenix.LiveView`."
  import Plug.Conn.Query, only: [encode: 1]
  use Phoenix.HTML

  import Phoenix.LiveView,
    only: [live_render: 2, live_render: 3, live_link: 1, live_link: 2]

  @spec pagination(qp :: AdminThing.Live.params(), total_pages :: non_neg_integer()) :: any()
  @doc "Implements a default pagination."
  def pagination(qp, total_pages) do
    current_page = get_in(qp, ~w[page number]) || 1

    content_tag(:div, class: "pagination") do
      1..total_pages
      |> Enum.map(fn
        1 -> 1
        ^total_pages -> total_pages
        n when n < current_page - 1 -> nil
        n when n > current_page + 1 -> nil
        n -> n
      end)
      |> Enum.dedup()
      |> Enum.map(fn
        nil -> content_tag(:span, "...")
        ^current_page -> content_tag(:span, "#{current_page}")
        n -> live_link("#{n}", to: "?#{qp |> put_in(~w[page number], n) |> encode()}")
      end)
    end
  end

  @spec sort_link(key :: any(), qp :: AdminThing.Live.params(), opts :: keyword()) :: any()
  @doc "Implements a sort link."
  def sort_link(key, qp, opts \\ []) do
    text = Keyword.get(opts, :label, Macro.camelize(key))

    params =
      case qp["sort"] do
        ^key -> qp |> put_in(~w[page number], 1) |> put_in(~w[sort], "-#{key}")
        _ -> qp |> put_in(~w[page number], 1) |> put_in(~w[sort], key)
      end

    content =
      case qp["sort"] do
        ^key -> "#{text} 🔼"
        "-" <> ^key -> "#{text} 🔽"
        _ -> text
      end

    live_link(content, to: "?" <> encode(params))
  end

  @spec filter(key :: any(), qp :: AdminThing.Live.params(), opts :: keyword()) :: any()
  @doc "Implements a filter."
  def filter(key, qp, _opts \\ []) do
    text_input(:filter, key, value: get_in(qp, ["filter", key]), phx_debounce: 100)
  end
end
