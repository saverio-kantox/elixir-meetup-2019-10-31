defmodule ExMeetup.Admin do
  @moduledoc """
  The Admin context.
  """

  import Ecto.Query, warn: false
  alias ExMeetup.Repo

  alias ExMeetup.Admin.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(params \\ %{}) do
    query_users(params)
    |> Repo.all()
  end

  def get_user_page_count(params \\ %{}) do
    query_users(params)
    |> exclude(:limit)
    |> exclude(:offset)
    |> exclude(:order_by)
    |> select([u], count(u.id, :distinct))
    |> Repo.one()
    |> case do
      0 -> 1
      n -> Integer.floor_div(n - 1, get_in(params, ~w[page size])) + 1
    end
  end

  defp query_users(params) do
    page_size = get_in(params, ~w[page size])
    page_number = get_in(params, ~w[page number])

    User
    |> paginate(Map.get(params, "page"))
    |> sort(Map.get(params, "sort"))
    |> filter(Map.get(params, "filter"))
  end

  defp paginate(queryable, nil), do: queryable

  defp paginate(queryable, %{} = param) do
    page_size = Map.get(param, "size", 5)
    page_number = Map.get(param, "number", 1)
    from u in queryable, limit: ^page_size, offset: ^((page_number - 1) * page_size)
  end

  defp sort(queryable, nil), do: queryable
  defp sort(queryable, ""), do: queryable
  defp sort(queryable, "-" <> key), do: do_sort(queryable, {key, :desc})
  defp sort(queryable, key), do: do_sort(queryable, {key, :asc})

  # specific sorting behavior, sort on email's hostname
  defp do_sort(queryable, {"email", direction}) do
    from u in queryable, order_by: [{^direction, fragment("SPLIT_PART(email, '@', 2)")}]
  end

  # default sorting behavior, sort on given column
  defp do_sort(queryable, {key, direction}) do
    from u in queryable, order_by: ^[{direction, String.to_existing_atom(key)}]
  end

  defp filter(queryable, nil), do: queryable

  defp filter(queryable, %{} = filters) do
    Enum.reduce(filters, queryable, &do_filter(&2, &1))
  end

  defp do_filter(queryable, {key, "*" <> value}) do
    from u in queryable, where: ilike(field(u, ^String.to_existing_atom(key)), ^"%#{value}%")
  end

  defp do_filter(queryable, {key, value}) do
    from u in queryable, where: ^[{String.to_existing_atom(key), value}]
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
