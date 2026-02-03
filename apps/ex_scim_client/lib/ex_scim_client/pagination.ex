defmodule ExScimClient.Pagination do
  @moduledoc """
  Pagination configuration for list requests.

  ## Examples

      iex> pagination = ExScimClient.Pagination.new(50, 101)
      iex> pagination.count
      50
      iex> pagination.start_index
      101

  """

  @enforce_keys [:count]
  defstruct [:count, start_index: 1]

  @type t :: %__MODULE__{
          start_index: pos_integer(),
          count: pos_integer()
        }

  @doc """
  Creates a new pagination struct.

  ## Parameters

    * `count` - Maximum number of results to return
    * `start_index` - 1-based index of the first result (defaults to 1)

  ## Examples

      iex> pagination = ExScimClient.Pagination.new(25)
      iex> %ExScimClient.Pagination{count: 25, start_index: 1} = pagination

      iex> pagination = ExScimClient.Pagination.new(10, 51)
      iex> %ExScimClient.Pagination{count: 10, start_index: 51} = pagination

  """
  @spec new(pos_integer(), pos_integer()) :: %__MODULE__{}
  def new(count, start_index \\ 1)
      when is_integer(count) and count > 0 and is_integer(start_index) and start_index > 0 do
    %__MODULE__{count: count, start_index: start_index}
  end
end
