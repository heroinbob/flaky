defmodule TestsFailTest do
  use ExUnit.Case
  doctest TestsFail

  test "greets the world" do
    refute TestsFail.hello() == :world
  end

  test "this passes" do
    assert true
  end

  test "this also fails" do
    assert false
  end
end
