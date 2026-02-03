defmodule ExScimClient.Resources.Bulk do
  @moduledoc """
  Bulk operations resource.

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> operations = %{"Operations" => []}
      iex> {:ok, _response} = ExScimClient.Resources.Bulk.execute(client, operations)

  """

  alias ExScimClient.Client
  alias ExScimClient.Request

  @doc """
  Executes bulk operations.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `operations` - Map containing bulk operations

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> operations = %{"Operations" => [%{"method" => "POST", "path" => "/Users", "data" => %{"userName" => "newuser"}}]}
      iex> {:ok, _response} = ExScimClient.Resources.Bulk.execute(client, operations)

  """
  @spec execute(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def execute(%Client{} = client, operations) do
    Request.new(client)
    |> Request.path("/Bulk")
    |> Request.method(:post)
    |> Request.body(operations)
    |> Request.run()
  end
end
