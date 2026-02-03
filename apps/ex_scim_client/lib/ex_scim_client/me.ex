defmodule ExScimClient.Me do
  @moduledoc """
  Operations on the authenticated user's own resource (`/Me` endpoint).

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _me} = ExScimClient.Me.get(client)

  """

  alias ExScimClient.Client
  alias ExScimClient.Request

  @doc """
  Retrieves the authenticated user's resource.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `opts` - Options keyword list
      * `:attributes` - List of attributes to include
      * `:excluded_attributes` - List of attributes to exclude

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _me} = ExScimClient.Me.get(client)
      iex> {:ok, _me} = ExScimClient.Me.get(client, attributes: ["userName", "displayName"])

  """
  @spec get(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, opts \\ []) do
    attributes = Keyword.get(opts, :attributes)
    excluded_attributes = Keyword.get(opts, :excluded_attributes)

    Request.new(client)
    |> Request.path("/Me")
    |> Request.method(:get)
    |> Request.attributes(attributes)
    |> Request.excluded_attributes(excluded_attributes)
    |> Request.run()
  end

  @doc """
  Updates the authenticated user's resource by replacing all attributes.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `user_data` - Map containing updated user attributes

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> user_data = %{displayName: "Updated Name"}
      iex> {:ok, _response} = ExScimClient.Me.update(client, user_data)

  """
  @spec update(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, user_data) when is_map(user_data) do
    Request.new(client)
    |> Request.path("/Me")
    |> Request.method(:put)
    |> Request.body(user_data)
    |> Request.run()
  end

  @doc """
  Partially updates the authenticated user's resource using patch operations.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `operations` - List of patch operations

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> operations = [%{"op" => "replace", "path" => "displayName", "value" => "New Name"}]
      iex> {:ok, _response} = ExScimClient.Me.patch(client, operations)

  """
  @spec patch(Client.t(), list()) :: {:ok, map()} | {:error, term()}
  def patch(%Client{} = client, operations) when is_list(operations) do
    patch_body = %{
      "schemas" => ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
      "Operations" => operations
    }

    Request.new(client)
    |> Request.path("/Me")
    |> Request.method(:patch)
    |> Request.body(patch_body)
    |> Request.run()
  end
end
