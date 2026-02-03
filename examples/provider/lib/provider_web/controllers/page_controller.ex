defmodule ProviderWeb.PageController do
  use ProviderWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
