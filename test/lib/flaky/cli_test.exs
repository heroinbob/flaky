defmodule Flaky.CliTest do
  use ExUnit.Case, async: true

  alias ExUnit.CaptureIO
  alias Flaky.CLI

  @all_pass_app_dir Flaky.Test.Support.FakeApps.all_pass_app_dir()
  @fail_app_dir Flaky.Test.Support.FakeApps.fail_app_dir()

  describe "main/1" do
    test "runs the tests until default max_tests is reached and prints the success message" do
      output =
        CaptureIO.capture_io(fn ->
          assert :ok = CLI.main(["--app-dir", @all_pass_app_dir])
        end)

      assert String.contains?(output, "First test passed:")
      assert String.contains?(output, "6 tests, 0 failures")
      assert String.contains?(output, "Nothing was flaky!")
    end

    test "passes the supported optional params to the command" do
      # This flexes all the options even if it's not entirely realiztic.
      # The line scopes to the whole file basically and we ignore all errors
      # except the 1 test that always pasess.
      output =
        CaptureIO.capture_io(fn ->
          assert :ok =
                   CLI.main([
                     "--app-dir",
                     @fail_app_dir,
                     "--ignore-all-except",
                     "tests_fail_test.exs:10",
                     "--max-tests",
                     "10",
                     "--seed",
                     "1234",
                     "--test-path",
                     "test/tests_fail_test.exs:3"
                   ])
        end)

      # Assert it ran 10 times (max tests)
      assert String.contains?(output, "........\nMax tests has been reached")
      # Assert the scope - there are only 3 tests in the file
      assert String.contains?(output, "3 tests, 0 failures")
      assert String.contains?(output, "Randomized with seed 1234")

      # Asserts the line scope - even if it had no effect.
      assert String.contains?(
               output,
               ~s(Including tags: [location: {"test/tests_fail_test.exs", 3}])
             )
    end

    test "returns an error when the result is an error" do
      output =
        CaptureIO.capture_io(fn ->
          assert {:error, {2 = _exit_code, output}} = CLI.main(["--app-dir", @fail_app_dir])
          assert String.contains?(output, "3 tests, 2 failures")
        end)

      assert String.contains?(output, "Test failed!")
      assert String.contains?(output, "3 tests, 2 failures")
    end
  end
end
