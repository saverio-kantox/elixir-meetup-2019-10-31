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
end
