defmodule ExMeetupWeb.UserView do
  use ExMeetupWeb, :view
  import Plug.Conn.Query, only: [encode: 1]

  def pagination(qp, total_pages) do
    IO.inspect(qp)
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
        n -> live_link("#{n}", to: "?#{qp |> put_in(~w[page number], n) |> encode()}")
      end)
    end
  end

  def sort_link(text, qp, opts) do
    key = Keyword.fetch!(opts, :key)

    params =
      case qp["sort"] do
        ^key -> qp |> put_in(~w[page number], 1) |> put_in(~w[sort], "-#{key}")
        _ -> qp |> put_in(~w[page number], 1) |> put_in(~w[sort], key)
      end

    content = case qp["sort"] do
      ^key -> "#{text} 🔼"
      "-" <> ^key -> "#{text} 🔽"
      _ -> text
    end

    live_link(content, to: "?" <> encode(params))
  end
end
