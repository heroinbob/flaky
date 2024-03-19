defmodule AllTestsPass.MoarTest do
  use ExUnit.Case
  doctest AllTestsPass

  test "moar tests" do
    assert AllTestsPass.hello() == :world
  end

  test "even moar tests" do
    refute AllTestsPass.hello() == :hello
  end
end
