defmodule ExMeetupWeb.Admin.Users.IndexLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(ExMeetupWeb.UserView, "index.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    users = ExMeetup.Admin.list_users()

    params =
      params
      |> Map.put_new(:page, %{})
      |> update_in(~w[page number], fn
        nil -> 1
        n -> String.to_integer(n)
      end)
      |> update_in(~w[page size], fn
        nil -> 20
        n -> String.to_integer(n)
      end)

    socket = socket |> assign(users: users, query_params: params, total_pages: 10)
    {:noreply, socket}
  end
end
