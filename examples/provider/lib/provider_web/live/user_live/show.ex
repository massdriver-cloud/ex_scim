defmodule ProviderWeb.UserLive.Show do
  use ProviderWeb, :live_view

  alias Provider.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        User {@user.id}
        <:subtitle>This is a user record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/users"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/users/#{@user}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit user
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="External">{@user.external_id}</:item>
        <:item title="User name">{@user.user_name}</:item>
        <:item title="Given name">{@user.given_name}</:item>
        <:item title="Family name">{@user.family_name}</:item>
        <:item title="Email">{@user.email}</:item>
        <:item title="Active">{@user.active}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show User")
     |> assign(:user, Accounts.get_user!(id))}
  end
end
