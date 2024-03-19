defmodule AllTestsPass.EvenMoarTest do
  use ExUnit.Case
  doctest AllTestsPass

  @tag fake_tests: true
  test "so much moar tests" do
    assert AllTestsPass.hello() == :world
  end

  @tag fake_tests: true
  test "omg moar tests" do
    refute AllTestsPass.hello() == :hello
  end
end
