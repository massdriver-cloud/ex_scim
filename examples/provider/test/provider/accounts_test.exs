defmodule Provider.AccountsTest do
  use Provider.DataCase

  alias Provider.Accounts

  describe "users" do
    alias Provider.Accounts.User

    import Provider.AccountsFixtures

    @invalid_attrs %{
      active: nil,
      external_id: nil,
      user_name: nil,
      given_name: nil,
      family_name: nil,
      email: nil
    }

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        active: true,
        external_id: "some external_id",
        user_name: "some user_name",
        given_name: "some given_name",
        family_name: "some family_name",
        email: "some email"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.active == true
      assert user.external_id == "some external_id"
      assert user.user_name == "some user_name"
      assert user.given_name == "some given_name"
      assert user.family_name == "some family_name"
      assert user.email == "some email"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        active: false,
        external_id: "some updated external_id",
        user_name: "some updated user_name",
        given_name: "some updated given_name",
        family_name: "some updated family_name",
        email: "some updated email"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.active == false
      assert user.external_id == "some updated external_id"
      assert user.user_name == "some updated user_name"
      assert user.given_name == "some updated given_name"
      assert user.family_name == "some updated family_name"
      assert user.email == "some updated email"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "groups" do
    alias Provider.Accounts.Group

    import Provider.AccountsFixtures

    @invalid_attrs %{
      active: nil,
      description: nil,
      display_name: nil,
      external_id: nil,
      meta_created: nil,
      meta_last_modified: nil
    }

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Accounts.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Accounts.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      valid_attrs = %{
        active: true,
        description: "some description",
        display_name: "some display_name",
        external_id: "some external_id",
        meta_created: ~U[2025-08-15 06:20:00.000000Z],
        meta_last_modified: ~U[2025-08-15 06:20:00.000000Z]
      }

      assert {:ok, %Group{} = group} = Accounts.create_group(valid_attrs)
      assert group.active == true
      assert group.description == "some description"
      assert group.display_name == "some display_name"
      assert group.external_id == "some external_id"
      assert group.meta_created == ~U[2025-08-15 06:20:00.000000Z]
      assert group.meta_last_modified == ~U[2025-08-15 06:20:00.000000Z]
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()

      update_attrs = %{
        active: false,
        description: "some updated description",
        display_name: "some updated display_name",
        external_id: "some updated external_id",
        meta_created: ~U[2025-08-16 06:20:00.000000Z],
        meta_last_modified: ~U[2025-08-16 06:20:00.000000Z]
      }

      assert {:ok, %Group{} = group} = Accounts.update_group(group, update_attrs)
      assert group.active == false
      assert group.description == "some updated description"
      assert group.display_name == "some updated display_name"
      assert group.external_id == "some updated external_id"
      assert group.meta_created == ~U[2025-08-16 06:20:00.000000Z]
      assert group.meta_last_modified == ~U[2025-08-16 06:20:00.000000Z]
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_group(group, @invalid_attrs)
      assert group == Accounts.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Accounts.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Accounts.change_group(group)
    end
  end
end
