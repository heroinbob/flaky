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

      {:ok, {:ignored, output}} ->
        new_count = count + 1

        if new_count <= max_tests do
          puts("\nFailure ignored:\n\n#{output}")
          test(opts, new_count)
        else
          puts("\nMax tests has been reached. Nothing was flaky!")
          :ok
        end

      {:ok, output} ->
        new_count = count + 1

        cond do
          count == 1 ->
            # Always print first test results. This allows one to compare a good run against
            # a bad run with any debug values being printed out.
            puts("First test passed:\n\n#{output}")
            test(opts, new_count)

          new_count <= max_tests ->
            count |> get_progress() |> write()
            test(opts, new_count)

          true ->
            puts("\nMax tests has been reached. Nothing was flaky!")
            :ok
        end
    end
  end
end
