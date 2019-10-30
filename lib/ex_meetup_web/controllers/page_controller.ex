defmodule ExMeetupWeb.PageController do
  use ExMeetupWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
