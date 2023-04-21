defmodule FlakyTest do
  use ExUnit.Case
  doctest Flaky

  test "greets the world" do
    assert Flaky.hello() == :world
  end
end
