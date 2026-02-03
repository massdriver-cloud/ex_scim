defmodule ExScimEctoTest do
  use ExUnit.Case
  doctest ExScimEcto

  test "provides version information" do
    version = ExScimEcto.version()
    assert is_binary(version)
    assert String.length(version) > 0
  end
end
