defmodule ProviderWeb.GroupLiveTest do
  use ProviderWeb.ConnCase

  import Phoenix.LiveViewTest
  import Provider.AccountsFixtures

  defp create_group(_) do
    group = group_fixture()
    %{group: group}
  end

  describe "Index" do
    setup [:create_group]

    test "lists all groups", %{conn: conn, group: group} do
      {:ok, _index_live, html} = live(conn, ~p"/groups")

      assert html =~ "Listing Groups"
      assert html =~ group.description
    end

    test "saves new group", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/groups")

      assert {:error, {:live_redirect, %{to: "/groups/new"}}} =
               index_live |> element("a", "New Group") |> render_click()

      {:ok, new_live, _html} = live(conn, ~p"/groups/new")
      assert render(new_live) =~ "New Group"

      {:ok, _index_live, _html} = live(conn, ~p"/groups")
    end

    test "updates group in listing", %{conn: conn, group: group} do
      {:ok, index_live, _html} = live(conn, ~p"/groups")

      expected_url = "/groups/#{group.id}/edit"

      assert {:error, {:live_redirect, %{to: ^expected_url}}} =
               index_live |> element("#groups-#{group.id} a", "Edit") |> render_click()

      {:ok, edit_live, _html} = live(conn, ~p"/groups/#{group}/edit")
      assert render(edit_live) =~ "Edit"

      {:ok, _index_live, _html} = live(conn, ~p"/groups")
    end

    test "deletes group in listing", %{conn: conn, group: group} do
      {:ok, index_live, _html} = live(conn, ~p"/groups")

      assert index_live |> element("#groups-#{group.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#groups-#{group.id}")
    end
  end

  describe "Show" do
    setup [:create_group]

    test "displays group", %{conn: conn, group: group} do
      {:ok, _show_live, html} = live(conn, ~p"/groups/#{group}")

      assert html =~ "Show Group"
      assert html =~ group.description
    end

    test "updates group within modal", %{conn: conn, group: group} do
      {:ok, show_live, _html} = live(conn, ~p"/groups/#{group}")

      expected_url = "/groups/#{group.id}/edit?return_to=show"

      assert {:error, {:live_redirect, %{to: ^expected_url}}} =
               show_live |> element("a", "Edit") |> render_click()

      {:ok, edit_live, _html} = live(conn, ~p"/groups/#{group}/edit?return_to=show")
      assert render(edit_live) =~ "Edit"

      {:ok, _show_live, _html} = live(conn, ~p"/groups/#{group}")
    end
  end
end
