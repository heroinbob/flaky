defmodule Flaky.CLI do
  @moduledoc """
  The command line interface for Flaky.

  Usage:
    flaky [options]

  Options:
    --app_dir, -a           Absolute path to the app dir to test with.
    --ignore_all_except, -i String or list of strings to treat as a test failure.
    --max_tests, -m         Max tests to run. Default is #{Flaky.Options.default_max_tests()}.
    --seed, -s              Seed to use instead of a random one.
    --test_path, -t         Relative path from app dir to the dir to test. Default is "test".
                            This value will be passed to the command so you can provide a filename
                            and line number as well.

  ## Examples

    `./flaky --app_dir /home/me/`
    `./flaky --app_dir /home/me/ --test-path /test/folder/`
    `./flaky --app_dir /home/me/ --test-path /test/folder/filename.exs`
    `./flaky --app_dir /home/me/ --test-path /test/folder/filename.exs:42`
  """
  import Flaky.Printer

  alias Flaky.Options

  def main(args \\ []) do
    args
    |> Options.from_argv()
    |> tap(fn _opts -> print_info("Starting tests...") end)
    |> Flaky.test()
  end
end
