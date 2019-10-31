defmodule ExMeetupWeb.Admin.Users.IndexLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(ExMeetupWeb.UserView, "index.html", assigns)
  end

  def handle_params(params, _uri, socket) do
    users = ExMeetup.Admin.list_users()
    {:noreply, assign(socket, users: users)}
  end
end
