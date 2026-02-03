defmodule Provider.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Provider.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])

    {:ok, user} =
      attrs
      |> Enum.into(%{
        active: true,
        email: "user#{unique_id}@example.com",
        external_id: "external_id_#{unique_id}",
        family_name: "some family_name",
        given_name: "some given_name",
        user_name: "user_#{unique_id}"
      })
      |> Provider.Accounts.create_user()

    user
  end

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])

    {:ok, group} =
      attrs
      |> Enum.into(%{
        active: true,
        description: "some description",
        display_name: "some display_name",
        external_id: "external_group_id_#{unique_id}",
        meta_created: ~U[2025-08-15 06:20:00.000000Z],
        meta_last_modified: ~U[2025-08-15 06:20:00.000000Z]
      })
      |> Provider.Accounts.create_group()

    group
  end
end
