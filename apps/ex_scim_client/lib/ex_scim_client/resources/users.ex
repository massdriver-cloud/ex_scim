defmodule ExScimClient.Resources.Users do
  @moduledoc """
  User resource operations.

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _response} = ExScimClient.Resources.Users.create(client, %{userName: "jdoe"})

  """

  alias ExScimClient.Client
  alias ExScimClient.Request

  @doc """
  Creates a new user.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `user_data` - Map containing user attributes

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> user_data = %{userName: "jdoe", name: %{givenName: "John", familyName: "Doe"}}
      iex> {:ok, _response} = ExScimClient.Resources.Users.create(client, user_data)

  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, user_data) when is_map(user_data) do
    Request.new(client)
    |> Request.path("/Users")
    |> Request.method(:post)
    |> Request.body(user_data)
    |> Request.run()
  end

  @doc """
  Retrieves a user by ID.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `id` - User ID string
    * `opts` - Options keyword list
      * `:attributes` - List of attributes to include
      * `:excluded_attributes` - List of attributes to exclude

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _user} = ExScimClient.Resources.Users.get(client, "user-123")
      iex> {:ok, _user} = ExScimClient.Resources.Users.get(client, "user-123", attributes: ["userName", "emails"])

  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, id, opts \\ []) when is_binary(id) do
    attributes = Keyword.get(opts, :attributes)
    excluded_attributes = Keyword.get(opts, :excluded_attributes)

    Request.new(client)
    |> Request.path("/Users/#{id}")
    |> Request.method(:get)
    |> Request.attributes(attributes)
    |> Request.excluded_attributes(excluded_attributes)
    |> Request.run()
  end

  @doc """
  Lists users with optional filtering, sorting, and pagination.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `opts` - Options keyword list
      * `:filter` - Filter string or `ExScimClient.Filter` struct
      * `:sorting` - `ExScimClient.Sorting` struct
      * `:pagination` - `ExScimClient.Pagination` struct
      * `:attributes` - List of attributes to include
      * `:excluded_attributes` - List of attributes to exclude

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _response} = ExScimClient.Resources.Users.list(client)
      iex> {:ok, _response} = ExScimClient.Resources.Users.list(client, filter: "userName eq \"jdoe\"")

  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, opts \\ []) do
    filter = Keyword.get(opts, :filter)
    sorting = Keyword.get(opts, :sorting)
    pagination = Keyword.get(opts, :pagination)
    attributes = Keyword.get(opts, :attributes)
    excluded_attributes = Keyword.get(opts, :excluded_attributes)

    Request.new(client)
    |> Request.path("/Users")
    |> Request.method(:get)
    |> Request.filter(filter)
    |> Request.sort_by(sorting)
    |> Request.paginate(pagination)
    |> Request.attributes(attributes)
    |> Request.excluded_attributes(excluded_attributes)
    |> Request.run()
  end

  @doc """
  Updates a user by replacing all attributes.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `id` - User ID string
    * `user_data` - Map containing updated user attributes

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> user_data = %{userName: "jdoe", displayName: "John Doe Updated"}
      iex> {:ok, _response} = ExScimClient.Resources.Users.update(client, "user-123", user_data)

  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, id, user_data) when is_binary(id) and is_map(user_data) do
    Request.new(client)
    |> Request.path("/Users/#{id}")
    |> Request.method(:put)
    |> Request.body(user_data)
    |> Request.run()
  end

  @doc """
  Partially updates a user using patch operations.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `id` - User ID string
    * `operations` - List of patch operations

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> operations = [%{"op" => "replace", "path" => "displayName", "value" => "New Name"}]
      iex> {:ok, _response} = ExScimClient.Resources.Users.patch(client, "user-123", operations)

  """
  @spec patch(Client.t(), String.t(), list()) :: {:ok, map()} | {:error, term()}
  def patch(%Client{} = client, id, operations)
      when is_binary(id) and is_list(operations) do
    patch_body = %{
      "schemas" => ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
      "Operations" => operations
    }

    Request.new(client)
    |> Request.path("/Users/#{id}")
    |> Request.method(:patch)
    |> Request.body(patch_body)
    |> Request.run()
  end

  @doc """
  Deletes a user.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `id` - User ID string

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _response} = ExScimClient.Resources.Users.delete(client, "user-123")

  """
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, id) when is_binary(id) do
    Request.new(client)
    |> Request.path("/Users/#{id}")
    |> Request.method(:delete)
    |> Request.run()
  end
end
