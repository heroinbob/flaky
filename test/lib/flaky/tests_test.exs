defmodule Flaky.TestsTest do
  use ExUnit.Case, async: true

  alias Flaky.Tests

  describe "perform/1" do
    test "invokes the correct command when given only test path" do
      assert {:ok, pid} = Tests.perform(test_path: "a_path")
    end

    test "invokes the correct command when given test path and filename"
    test "invokes the correct command when given test path, filename, line"
  end

  defmodule TestProctor do
    def test_failed do
    end

    def test_passed do
    end
  end
end
