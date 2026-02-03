defmodule ClientWeb.PageController do
  use ClientWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
