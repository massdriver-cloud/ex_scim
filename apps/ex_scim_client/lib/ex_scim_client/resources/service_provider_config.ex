defmodule ExScimClient.Resources.ServiceProviderConfig do
  alias ExScimClient.Client
  alias ExScimClient.Request

  def get(%Client{} = client) do
    Request.new(client)
    |> Request.path("/ServiceProviderConfig")
    |> Request.method(:get)
    |> Request.run()
  end
end
