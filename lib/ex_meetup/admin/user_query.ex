defmodule ExMeetup.Admin.UserQuery do
  use AdminThing.Query

  def base_queryable(), do: ExMeetup.Admin.User
  def repo(), do: ExMeetup.Repo

  # specific sorting behavior, sort on email's hostname
  defp do_sort(queryable, {:email, direction}) do
    from u in queryable, order_by: [{^direction, fragment("SPLIT_PART(email, '@', 2)")}]
  end

  # specific filter behavior, insensitive match substring
  defp do_filter(queryable, {:name, "*" <> value}) do
    from u in queryable, where: ilike(u.name, ^"%#{value}%")
  end
end
