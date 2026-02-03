defmodule ProviderWeb.GroupLive.Show do
  use ProviderWeb, :live_view

  alias Provider.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Group {@group.id}
        <:subtitle>This is a group record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/groups"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/groups/#{@group}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit group
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Display name">{@group.display_name}</:item>
        <:item title="Description">{@group.description}</:item>
        <:item title="External">{@group.external_id}</:item>
        <:item title="Active">{@group.active}</:item>
        <:item title="Meta created">{@group.meta_created}</:item>
        <:item title="Meta last modified">{@group.meta_last_modified}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Group")
     |> assign(:group, Accounts.get_group!(id))}
  end
end
