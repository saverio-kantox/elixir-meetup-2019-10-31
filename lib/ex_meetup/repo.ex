defmodule ExMeetup.Repo do
  use Ecto.Repo,
    otp_app: :ex_meetup,
    adapter: Ecto.Adapters.Postgres
end
