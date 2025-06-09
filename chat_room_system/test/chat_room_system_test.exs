defmodule ChatRoomSystemTest do
  use ExUnit.Case
  doctest ChatRoomSystem

  test "greets the world" do
    assert ChatRoomSystem.hello() == :world
  end
end
