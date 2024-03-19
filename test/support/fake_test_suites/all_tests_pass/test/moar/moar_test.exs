defmodule AllTestsPass.MoarTest do
  use ExUnit.Case
  doctest AllTestsPass

  @tag fake_tests: true
  test "moar tests" do
    assert AllTestsPass.hello() == :world
  end

  @tag fake_tests: true
  test "even moar tests" do
    refute AllTestsPass.hello() == :hello
  end
end
