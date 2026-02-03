defmodule ExScimPhoenix.Test.ConnHelpers do
  def decode_response(conn) do
    Jason.decode!(conn.resp_body)
  end
end
