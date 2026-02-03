defmodule ProviderWeb.UserLiveTest do
  use ProviderWeb.ConnCase

  import Phoenix.LiveViewTest
  import Provider.AccountsFixtures

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  describe "Index" do
    setup [:create_user]

    test "lists all users", %{conn: conn, user: user} do
      {:ok, _index_live, html} = live(conn, ~p"/users")

      assert html =~ "Listing Users"
      assert html =~ user.external_id
    end

    test "saves new user", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/users")

      assert {:error, {:live_redirect, %{to: "/users/new"}}} =
               index_live |> element("a", "New User") |> render_click()

      {:ok, new_live, _html} = live(conn, ~p"/users/new")
      assert render(new_live) =~ "New User"

      {:ok, _index_live, _html} = live(conn, ~p"/users")
    end

    test "updates user in listing", %{conn: conn, user: user} do
      {:ok, index_live, _html} = live(conn, ~p"/users")

      expected_url = "/users/#{user.id}/edit"

      assert {:error, {:live_redirect, %{to: ^expected_url}}} =
               index_live |> element("#users-#{user.id} a", "Edit") |> render_click()

      {:ok, edit_live, _html} = live(conn, ~p"/users/#{user}/edit")
      assert render(edit_live) =~ "Edit"

      {:ok, _index_live, _html} = live(conn, ~p"/users")
    end

    test "deletes user in listing", %{conn: conn, user: user} do
      {:ok, index_live, _html} = live(conn, ~p"/users")

      assert index_live |> element("#users-#{user.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#users-#{user.id}")
    end
  end

  describe "Show" do
    setup [:create_user]

    test "displays user", %{conn: conn, user: user} do
      {:ok, _show_live, html} = live(conn, ~p"/users/#{user}")

      assert html =~ "Show User"
      assert html =~ user.external_id
    end

    test "updates user within modal", %{conn: conn, user: user} do
      {:ok, show_live, _html} = live(conn, ~p"/users/#{user}")

      expected_url = "/users/#{user.id}/edit?return_to=show"

      assert {:error, {:live_redirect, %{to: ^expected_url}}} =
               show_live |> element("a", "Edit") |> render_click()

      {:ok, edit_live, _html} = live(conn, ~p"/users/#{user}/edit?return_to=show")
      assert render(edit_live) =~ "Edit"

      {:ok, _show_live, _html} = live(conn, ~p"/users/#{user}")
    end
  end
end
