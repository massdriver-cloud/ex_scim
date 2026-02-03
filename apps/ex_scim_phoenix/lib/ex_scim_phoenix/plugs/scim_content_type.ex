defmodule ExScimPhoenix.Plugs.ScimContentType do
  @moduledoc """
  Handles SCIM-specific content type negotiation per RFC 7644
  """
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    conn
    |> put_resp_content_type("application/scim+json", "utf-8")
    |> assign(:scim_version, "2.0")
  end
end
