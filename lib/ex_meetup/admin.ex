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
    IO.inspect(params)

    case Repo.one(
           from u in (query_users(params) |> exclude(:limit) |> exclude(:offset)),
             select: count(u.id, :distinct)
         ) do
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
  end

  defp paginate(queryable, nil), do: queryable

  defp paginate(queryable, %{} = param) do
    page_size = Map.get(param, "size", 5)
    page_number = Map.get(param, "number", 1)
    from u in queryable, limit: ^page_size, offset: (^page_size - 1) * ^page_number
  end

  defp sort(queryable, nil), do: queryable
  defp sort(queryable, ""), do: queryable
  defp sort(queryable, "-" <> key), do: do_sort(queryable, key, :desc)
  defp sort(queryable, key), do: do_sort(queryable, key, :asc)

  defp do_sort(q, key, direction), do: q

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
