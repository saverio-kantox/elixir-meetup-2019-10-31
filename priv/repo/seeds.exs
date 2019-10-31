# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ExMeetup.Repo.insert!(%ExMeetup.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ExMeetup.Repo
alias ExMeetup.Admin.User
alias ExMeetup.Payments.Payment

users =
  1..100
  |> Enum.map(fn _ ->
    %User{
      email: Faker.Internet.email(),
      name: Faker.Name.name()
    }
    |> Repo.insert!()
  end)

payments =
  1..200
  |> Enum.map(fn _ ->
    %Payment{
      amount:
        Faker.Random.Elixir.random_uniform() * Faker.Random.Elixir.random_between(1, 1_000_000),
      currency: Faker.Util.pick(~w[EUR USD GBP]),
      state: Faker.Util.pick(~w[ok pending blocked]),
      value_date: Faker.Date.between(~D[2018-12-10], ~D[2020-12-25])
    }
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:user, Faker.Util.pick(users))
    |> Repo.insert!()
  end)
