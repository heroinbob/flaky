defmodule AllTestsPass.EvenMoarTest do
  use ExUnit.Case
  doctest AllTestsPass

  test "so much moar tests" do
    assert AllTestsPass.hello() == :world
  end

  test "omg moar tests" do
    refute AllTestsPass.hello() == :hello
  end
end
