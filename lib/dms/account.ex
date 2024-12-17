defmodule Dms.Accounts do
  alias Dms.Repo
  alias Dms.User

  def get_or_create_user(username) do
    case Repo.get_by(User, username: username) do
      nil ->
        %User{}
        |> User.changeset(%{username: username})
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end
end
