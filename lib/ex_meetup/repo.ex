defmodule ExMeetup.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :ex_meetup,
    adapter: Ecto.Adapters.Postgres
end
