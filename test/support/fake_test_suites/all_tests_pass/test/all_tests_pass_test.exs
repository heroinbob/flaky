defmodule AllTestsPassTest do
  use ExUnit.Case
  doctest AllTestsPass

  @tag fake_tests: true
  test "greets the world" do
    assert AllTestsPass.hello() == :world
  end

  @tag fake_tests: true
  test "just a second test so we can scope to individual tests" do
    refute AllTestsPass.hello() == :hello
  end
end
