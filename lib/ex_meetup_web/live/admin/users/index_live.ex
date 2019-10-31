defmodule ExMeetupWeb.Admin.Users.IndexLive do
  use Phoenix.LiveView
  use AdminThing.Live, routes: ExMeetupWeb.Router.Helpers

  def render(assigns) do
    Phoenix.View.render(ExMeetupWeb.UserView, "index.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket = AdminThing.Live.load_data(socket, params, ExMeetup.Admin.UserQuery, into: :users)
    {:noreply, socket}
  end

  def handle_event("foo", _, socket) do
    {:noreply, socket}
  end
end
