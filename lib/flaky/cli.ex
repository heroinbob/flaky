defmodule Flaky.CLI do
  @moduledoc """
  The command line interface for Flaky.

  Usage:
    flaky [options]

  Options:
    --app_dir, -a           Absolute path to the app dir to test with.
    --filename, -f          Filename to test. Only used when app_dir is set.
    --ignore_all_except, -i String or list of strings to treat as a test failure.
    --line, -l              Line number to test. Only used when filename is set.
    --max_tests, -m         Max tests to run. Default is #{Flaky.Options.default_max_tests()}.
    --seed, -s              Seed to use instead of a random one.
    --test_path, -t         Relative path from app dir to the dir to test. Default is "test".
  """

  alias Flaky.Options
  alias Flaky.SynchronousTests

  defdelegate puts(string), to: IO
  defdelegate write(string), to: IO

  def main(args \\ []) do
    args
    |> Options.from_argv()
    |> tap(fn _opts -> puts("Starting tests...") end)
    |> test()
  end

  defp get_progress(count) do
    if Integer.mod(count, 10) == 0, do: count, else: "."
  end

  defp test(%{max_tests: max_tests} = opts, count \\ 1) do
    case SynchronousTests.perform(opts) do
      {:error, output} = error ->
        puts("\n\nTest failed!\n\n#{inspect(output)}")

        error

      {result, output} ->
        new_count = count + 1

        cond do
          count == 1 ->
            puts("First test passed:\n\n#{output}")
            test(opts, new_count)

          new_count <= max_tests ->
            if result == :ignored, do: puts("\nFailure ignored:\n\n#{output}")

            count |> get_progress() |> write()
            test(opts, new_count)

          true ->
            puts("\nMax tests has been reached. Nothing was flaky!")
            :ok
        end
    end
  end
end
