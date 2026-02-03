defmodule ExScimPhoenixTest do
  use ExUnit.Case
  doctest ExScimPhoenix

  test "provides version information" do
    version = ExScimPhoenix.version()
    assert is_binary(version)
    assert String.length(version) > 0
  end
end
