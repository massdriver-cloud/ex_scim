defmodule ExScimClient.Model.Infrastructure.Error do
  @moduledoc """
  Standard SCIM error representation (RFC 7644 §3.12)
  """

  @derive JSON.Encoder
  defstruct [
    :schemas,
    :scimType,
    :detail,
    :status
  ]

  @type t :: %__MODULE__{
          :schemas => [String.t()] | nil,
          :scimType => String.t() | nil,
          :detail => String.t() | nil,
          :status => String.t() | nil
        }

  def decode(value) do
    value
  end
end
