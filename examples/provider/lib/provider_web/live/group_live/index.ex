defmodule ProviderWeb.GroupLive.Index do
  use ProviderWeb, :live_view

  alias Provider.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Groups
        <:actions>
          <.button variant="primary" navigate={~p"/groups/new"}>
            <.icon name="hero-plus" /> New Group
          </.button>
        </:actions>
      </.header>

      <.table
        id="groups"
        rows={@streams.groups}
        row_click={fn {_id, group} -> JS.navigate(~p"/groups/#{group}") end}
      >
        <:col :let={{_id, group}} label="Display name">{group.display_name}</:col>
        <:col :let={{_id, group}} label="Description">{group.description}</:col>
        <:col :let={{_id, group}} label="External">{group.external_id}</:col>
        <:col :let={{_id, group}} label="Active">{group.active}</:col>
        <:col :let={{_id, group}} label="Meta created">{group.meta_created}</:col>
        <:col :let={{_id, group}} label="Meta last modified">{group.meta_last_modified}</:col>
        <:action :let={{_id, group}}>
          <div class="sr-only">
            <.link navigate={~p"/groups/#{group}"}>Show</.link>
          </div>
          <.link navigate={~p"/groups/#{group}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, group}}>
          <.link
            phx-click={JS.push("delete", value: %{id: group.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Groups")
     |> stream(:groups, Accounts.list_groups())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    group = Accounts.get_group!(id)
    {:ok, _} = Accounts.delete_group(group)

    {:noreply, stream_delete(socket, :groups, group)}
  end
end
