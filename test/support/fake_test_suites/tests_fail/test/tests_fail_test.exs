defmodule TestsFailTest do
  use ExUnit.Case
  doctest TestsFail

  @tag fake_tests: true
  test "greets the world" do
    refute TestsFail.hello() == :world
  end

  @tag fake_tests: true
  test "this passes" do
    assert true
  end

  @tag fake_tests: true
  test "this also fails" do
    assert false
  end
end
