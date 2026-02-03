defmodule ExScimClient.Resources.Schemas do
  @moduledoc """
  Schema resource operations.

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _schemas} = ExScimClient.Resources.Schemas.list(client)
      iex> {:ok, _user_schema} = ExScimClient.Resources.Schemas.user_schema(client)

  """

  alias ExScimClient.Client
  alias ExScimClient.Request

  @doc """
  Lists available schemas.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `opts` - Options keyword list (filter, sorting, pagination, attributes, excluded_attributes)

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _schemas} = ExScimClient.Resources.Schemas.list(client)

  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list(%Client{} = client, opts \\ []) do
    filter = Keyword.get(opts, :filter)
    sorting = Keyword.get(opts, :sorting)
    pagination = Keyword.get(opts, :pagination)
    attributes = Keyword.get(opts, :attributes)
    excluded_attributes = Keyword.get(opts, :excluded_attributes)

    Request.new(client)
    |> Request.path("/Schemas")
    |> Request.method(:get)
    |> Request.filter(filter)
    |> Request.sort_by(sorting)
    |> Request.paginate(pagination)
    |> Request.attributes(attributes)
    |> Request.excluded_attributes(excluded_attributes)
    |> Request.run()
  end

  @doc """
  Retrieves a specific schema by ID.

  ## Parameters

    * `client` - `ExScimClient.Client` struct
    * `schema_id` - Schema identifier (URI)
    * `opts` - Options keyword list

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _schema} = ExScimClient.Resources.Schemas.get(client, "urn:ietf:params:scim:schemas:core:2.0:User")

  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get(%Client{} = client, schema_id, opts \\ []) when is_binary(schema_id) do
    # URL encode the schema ID since it contains special characters
    encoded_id = URI.encode(schema_id, &URI.char_unreserved?/1)

    attributes = Keyword.get(opts, :attributes)
    excluded_attributes = Keyword.get(opts, :excluded_attributes)

    Request.new(client)
    |> Request.path("/Schemas/#{encoded_id}")
    |> Request.method(:get)
    |> Request.attributes(attributes)
    |> Request.excluded_attributes(excluded_attributes)
    |> Request.run()
  end

  @doc """
  Retrieves the User schema.

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _user_schema} = ExScimClient.Resources.Schemas.user_schema(client)

  """
  @spec user_schema(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def user_schema(%Client{} = client, opts \\ []) do
    get(client, "urn:ietf:params:scim:schemas:core:2.0:User", opts)
  end

  @doc """
  Retrieves the Group schema.

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _group_schema} = ExScimClient.Resources.Schemas.group_schema(client)

  """
  @spec group_schema(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def group_schema(%Client{} = client, opts \\ []) do
    get(client, "urn:ietf:params:scim:schemas:core:2.0:Group", opts)
  end

  @doc """
  Retrieves the Enterprise User schema.

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token")
      iex> {:ok, _enterprise_schema} = ExScimClient.Resources.Schemas.enterprise_user_schema(client)

  """
  @spec enterprise_user_schema(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def enterprise_user_schema(%Client{} = client, opts \\ []) do
    get(client, "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User", opts)
  end
end
