defmodule Flaky.SynchronousTestsTests do
  use ExUnit.Case, async: true

  alias Flaky.Options
  alias Flaky.SynchronousTests

  @all_pass_app_dir Flaky.Test.Support.FakeApps.all_pass_app_dir()
  @fail_app_dir Flaky.Test.Support.FakeApps.fail_app_dir()

  describe "perform/1" do
    test "runs the mix command scoped to the given app and returns the output" do
      options = %Options{app_dir: @all_pass_app_dir, test_path: "test"}

      assert {:ok, output} = SynchronousTests.perform(options)
      assert String.contains?(output, " 6 tests, 0 failures")
    end

    test "scopes to the given path when given" do
      options = %Options{app_dir: @all_pass_app_dir, test_path: "test/moar"}

      assert {:ok, output} = SynchronousTests.perform(options)
      assert String.contains?(output, " 4 tests, 0 failures")
    end

    test "scopes to the filename when given" do
      options = %Options{
        app_dir: @all_pass_app_dir,
        test_path: "test/all_tests_pass_test.exs"
      }

      assert {:ok, output} = SynchronousTests.perform(options)
      assert String.contains?(output, " 2 tests, 0 failures")
    end

    test "scopes to the given path and filename when given" do
      options = %Options{
        app_dir: @all_pass_app_dir,
        test_path: "test/moar/even_moar_test.exs"
      }

      assert {:ok, output} = SynchronousTests.perform(options)
      assert String.contains?(output, " 2 tests, 0 failures")
    end

    test "scopes to the line when given a file and line" do
      options = %Options{
        app_dir: @all_pass_app_dir,
        test_path: "test/all_tests_pass_test.exs:5"
      }

      assert {:ok, output} = SynchronousTests.perform(options)

      assert String.contains?(
               output,
               ~s(Including tags: [location: {"test/all_tests_pass_test.exs", 5}])
             )
    end

    test "includes the given seed" do
      options = %Options{
        app_dir: @all_pass_app_dir,
        seed: 42,
        test_path: "test"
      }

      assert {:ok, output} = SynchronousTests.perform(options)
      assert String.contains?(output, "Randomized with seed 42")
    end

    test "returns :error when there is a test failure" do
      options = %Options{
        app_dir: @fail_app_dir,
        test_path: "test"
      }

      assert {
               :error,
               {2 = _exit_code, output}
             } = SynchronousTests.perform(options)

      assert String.contains?(output, " 2 failures")
    end

    test "returns :ok with what was ignored when given :ignore_all_except and there's no match" do
      options = %Options{
        app_dir: @fail_app_dir,
        ignore_all_except: "fail_test.exs:10",
        test_path: "test"
      }

      assert {
               :ok,
               {:ignored, output}
             } = SynchronousTests.perform(options)

      assert String.contains?(output, " 2 failures")
    end

    test "returns :error when given :ignore_all_except and there's a match" do
      options = %Options{
        app_dir: @fail_app_dir,
        ignore_all_except: "tests_fail_test.exs:16",
        test_path: "test"
      }

      assert {
               :error,
               {2 = _exit_code, output}
             } = SynchronousTests.perform(options)

      assert String.contains?(output, " 2 failures")
    end

    test "supports sending a list of strings to treat as exceptions" do
      options = %Options{
        app_dir: @fail_app_dir,
        ignore_all_except: ["fail_test.exs:12345", "fail_test.exs:10"],
        test_path: "test"
      }

      assert {
               :ok,
               {:ignored, _output}
             } = SynchronousTests.perform(options)
    end
  end
end
