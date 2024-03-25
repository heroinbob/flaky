defmodule Flaky.OptionsTest do
  use ExUnit.Case, async: true

  alias Flaky.Options

  @max_tests Flaky.Options.default_max_tests()

  describe "from_argv/1" do
    test "returns a map when given app_dir" do
      assert Options.from_argv(["--app-dir", "test"]) == %Options{
               app_dir: "test",
               ignore_all_except: nil,
               max_tests: @max_tests,
               seed: nil,
               test_path: "test"
             }
    end

    test "returns a map with all supported values" do
      assert Options.from_argv(~w[
        --app-dir
        test
        --ignore-all-except
        tests_fail_test.exs:10
        --max-tests
        10
        --seed
        1234
        --test-path
        foo/tests_fail_test.exs:3
      ]) == %Options{
               app_dir: "test",
               ignore_all_except: "tests_fail_test.exs:10",
               max_tests: 10,
               seed: 1234,
               test_path: "foo/tests_fail_test.exs:3"
             }
    end

    test "raises an error when the params are invalid" do
      assert_raise OptionParser.ParseError, fn -> Flaky.Options.from_argv(["--app_dir"]) end
    end
  end
end
