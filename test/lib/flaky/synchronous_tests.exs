defmodule Flaky.SynchronousTestsTests do
  use ExUnit.Case, async: true

  alias Flaky.SynchronousTests

  @flaky_dir :flaky |> Application.app_dir() |> String.split("_build/") |> List.first()
  @all_pass_app_dir @flaky_dir <> "test/support/fake_test_suites/all_tests_pass"
  @fail_app_dir @flaky_dir <> "test/support/fake_test_suites/tests_fail"

  describe "perform/1" do
    test "runs the mix command scoped to the given app and returns the output" do
      assert {:ok, output} = SynchronousTests.perform(app_dir: @all_pass_app_dir)
      assert String.contains?(output, " 6 tests, 0 failures")
    end

    test "scopes to the given path when given" do
      assert {:ok, output} =
               SynchronousTests.perform(
                 app_dir: @all_pass_app_dir,
                 test_path: "test/moar"
               )

      assert String.contains?(output, " 4 tests, 0 failures")
    end

    test "scopes to the filename when given" do
      assert {:ok, output} =
               SynchronousTests.perform(
                 app_dir: @all_pass_app_dir,
                 filename: "all_tests_pass_test.exs"
               )

      assert String.contains?(output, " 2 tests, 0 failures")
    end

    test "scopes to the given path and filename when given" do
      assert {:ok, output} =
               SynchronousTests.perform(
                 app_dir: @all_pass_app_dir,
                 test_path: "test/moar",
                 filename: "even_moar_test.exs"
               )

      assert String.contains?(output, " 2 tests, 0 failures")
    end

    test "scopes to the line when given a file and line" do
      assert {:ok, output} =
               SynchronousTests.perform(
                 app_dir: @all_pass_app_dir,
                 filename: "all_tests_pass_test.exs",
                 line: 5
               )

      assert String.contains?(
               output,
               ~s(Including tags: [location: {"test/all_tests_pass_test.exs", 5}])
             )
    end

    test "includes the given seed" do
      assert {:ok, output} = SynchronousTests.perform(app_dir: @all_pass_app_dir, seed: 42)
      assert String.contains?(output, "Randomized with seed 42")
    end

    test "ignores the line when no filename is given" do
      assert {:ok, output} = SynchronousTests.perform(app_dir: @all_pass_app_dir, line: 666)
      assert String.contains?(output, " 6 tests, 0 failures")
      refute String.contains?(output, "666")
    end

    test "raises an error when :app_dir is not defined" do
      assert_raise KeyError, fn -> SynchronousTests.perform([]) end
    end

    test "returns :error when there is a test failure" do
      assert {
               :error,
               {2 = _exit_code, output}
             } = SynchronousTests.perform(app_dir: @fail_app_dir)

      assert String.contains?(output, " 2 failures")
    end

    test "returns :ok with what was ignored when given :ignore_all_except and there's no match" do
      assert {
               :ok,
               {:ignored, output}
             } =
               SynchronousTests.perform(
                 app_dir: @fail_app_dir,
                 ignore_all_except: "fail_test.exs:10"
               )

      assert String.contains?(output, " 2 failures")
    end

    test "returns :error when given :ignore_all_except and there's a match" do
      assert {
               :error,
               {2 = _exit_code, output}
             } =
               SynchronousTests.perform(
                 app_dir: @fail_app_dir,
                 ignore_all_except: "fail_test.exs:14"
               )

      assert String.contains?(output, " 2 failures")
    end

    test "supports sending a list of strings to treat as exceptions" do
      assert {
               :ok,
               {:ignored, _output}
             } =
               SynchronousTests.perform(
                 app_dir: @fail_app_dir,
                 ignore_all_except: ["fail_test.exs:1, fail_test.exs:10"]
               )
    end

    test "returns an error when the given app_dir doesn't exist" do
      # assert {
      #          :error,
      #          {2 = _exit_code, output}
      #        } =
      #          SynchronousTests.perform(app_dir: "foo", test_path: "bar")

      # assert String.contains?(output, " 2 failures")
    end
  end
end
