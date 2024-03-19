defmodule Flaky.Test.Support.FakeApps do
  @flaky_dir :flaky |> Application.app_dir() |> String.split("_build/") |> List.first()
  @all_pass_app_dir @flaky_dir <> "test/support/fake_test_suites/all_tests_pass"
  @fail_app_dir @flaky_dir <> "test/support/fake_test_suites/tests_fail"

  def all_pass_app_dir, do: @all_pass_app_dir
  def fail_app_dir, do: @fail_app_dir
end
