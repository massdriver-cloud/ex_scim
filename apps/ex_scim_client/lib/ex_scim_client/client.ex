defmodule ExScimClient.Client do
  @moduledoc """
  Client configuration struct.

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "token123")
      iex> client.base_url
      "https://example.com/scim/v2"
      iex> client.bearer
      "token123"

  """

  @type t :: %__MODULE__{
          base_url: String.t(),
          bearer: String.t(),
          default_headers: list({String.t(), String.t()})
        }

  defstruct [
    :base_url,
    :bearer,
    default_headers: [
      {"content-type", "application/scim+json"},
      {"accept", "application/scim+json"}
    ]
  ]

  @doc """
  Creates a new client configuration.

  ## Parameters

    * `base_url` - Provider base URL
    * `bearer` - Bearer token for authentication

  ## Examples

      iex> client = ExScimClient.Client.new("https://example.com/scim/v2", "abc123")
      iex> %ExScimClient.Client{base_url: "https://example.com/scim/v2", bearer: "abc123"} = client

  """
  @spec new(String.t(), String.t()) :: %__MODULE__{}
  def new(base_url, bearer), do: %__MODULE__{base_url: base_url, bearer: bearer}
end
