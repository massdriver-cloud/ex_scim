defmodule ExScimClient.Resources.Groups do
  @moduledoc """
  Group resource operations.

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _response} = ExScimClient.Resources.Groups.create(client, %{displayName: "Administrators"})

  """

  alias ExScimClient.Client
  alias ExScimClient.Request

  @doc """
  Creates a new group.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `group_data` - Map containing group attributes

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> group_data = %{displayName: "Developers", members: []}
      iex> {:ok, _response} = ExScimClient.Resources.Groups.create(client, group_data)

  """
  @spec create(Client.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(%Client{} = client, group_data) when is_map(group_data) do
    Request.new(client)
    |> Request.path("/Groups")
    |> Request.method(:post)
    |> Request.body(group_data)
    |> Request.run()
  end

  @doc """
  Retrieves a group by ID.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `id` - Group ID string
    * `opts` - Options keyword list
      * `:attributes` - List of attributes to include
      * `:excluded_attributes` - List of attributes to exclude

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _group} = ExScimClient.Resources.Groups.get(client, "group-123")
      iex> {:ok, _group} = ExScimClient.Resources.Groups.get(client, "group-123", attributes: ["displayName", "members"])

  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, id, opts \\ []) when is_binary(id) do
    attributes = Keyword.get(opts, :attributes)
    excluded_attributes = Keyword.get(opts, :excluded_attributes)

    Request.new(client)
    |> Request.path("/Groups/#{id}")
    |> Request.method(:get)
    |> Request.attributes(attributes)
    |> Request.excluded_attributes(excluded_attributes)
    |> Request.run()
  end

  @doc """
  Lists groups with optional filtering, sorting, and pagination.

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
      iex> {:ok, _response} = ExScimClient.Resources.Groups.list(client)
      iex> {:ok, _response} = ExScimClient.Resources.Groups.list(client, filter: "displayName eq \"Administrators\"")

  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, opts \\ []) do
    filter = Keyword.get(opts, :filter)
    sorting = Keyword.get(opts, :sorting)
    pagination = Keyword.get(opts, :pagination)
    attributes = Keyword.get(opts, :attributes)
    excluded_attributes = Keyword.get(opts, :excluded_attributes)

    Request.new(client)
    |> Request.path("/Groups")
    |> Request.method(:get)
    |> Request.filter(filter)
    |> Request.sort_by(sorting)
    |> Request.paginate(pagination)
    |> Request.attributes(attributes)
    |> Request.excluded_attributes(excluded_attributes)
    |> Request.run()
  end

  @doc """
  Updates a group by replacing all attributes.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `id` - Group ID string
    * `group_data` - Map containing updated group attributes

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> group_data = %{displayName: "Updated Group Name"}
      iex> {:ok, _response} = ExScimClient.Resources.Groups.update(client, "group-123", group_data)

  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update(%Client{} = client, id, group_data) when is_binary(id) and is_map(group_data) do
    Request.new(client)
    |> Request.path("/Groups/#{id}")
    |> Request.method(:put)
    |> Request.body(group_data)
    |> Request.run()
  end

  @doc """
  Partially updates a group using patch operations.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `id` - Group ID string
    * `operations` - List of patch operations

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> operations = [%{"op" => "replace", "path" => "displayName", "value" => "New Group Name"}]
      iex> {:ok, _response} = ExScimClient.Resources.Groups.patch(client, "group-123", operations)

  """
  @spec patch(Client.t(), String.t(), list()) :: {:ok, map()} | {:error, term()}
  def patch(%Client{} = client, id, operations)
      when is_binary(id) and is_list(operations) do
    patch_body = %{
      "schemas" => ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
      "Operations" => operations
    }

    Request.new(client)
    |> Request.path("/Groups/#{id}")
    |> Request.method(:patch)
    |> Request.body(patch_body)
    |> Request.run()
  end

  @doc """
  Deletes a group.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `id` - Group ID string

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _response} = ExScimClient.Resources.Groups.delete(client, "group-123")

  """
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete(%Client{} = client, id) when is_binary(id) do
    Request.new(client)
    |> Request.path("/Groups/#{id}")
    |> Request.method(:delete)
    |> Request.run()
  end
end
