defmodule AllTestsPassTest do
  use ExUnit.Case
  doctest AllTestsPass

  test "greets the world" do
    assert AllTestsPass.hello() == :world
  end

  test "just a second test so we can scope to individual tests" do
    refute AllTestsPass.hello() == :hello
  end
end
