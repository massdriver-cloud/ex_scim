defmodule ExScimClient.Sorting do
  @moduledoc """
  Sorting configuration for list requests.

  ## Examples

      iex> sorting = ExScimClient.Sorting.new("meta.created")
      iex> sorting.by
      "meta.created"
      iex> sorting.order
      :asc

      iex> sorting = ExScimClient.Sorting.new("displayName", :desc)
      iex> sorting.order
      :desc

  """

  @enforce_keys [:by]
  defstruct [:by, order: :asc]

  @type t :: %__MODULE__{
          by: String.t(),
          order: :asc | :desc
        }

  @doc """
  Creates a new sorting struct.

  ## Parameters

    * `by` - Attribute name to sort by
    * `order` - Sort order, either `:asc` (default) or `:desc`

  ## Examples

      iex> sorting = ExScimClient.Sorting.new("userName")
      iex> %ExScimClient.Sorting{by: "userName", order: :asc} = sorting

      iex> sorting = ExScimClient.Sorting.new("meta.lastModified", :desc)
      iex> %ExScimClient.Sorting{by: "meta.lastModified", order: :desc} = sorting

  """
  @spec new(String.t(), :asc | :desc) :: %__MODULE__{}
  def new(by, order \\ :asc) when is_binary(by) and order in [:asc, :desc] do
    %__MODULE__{by: by, order: order}
  end
end
