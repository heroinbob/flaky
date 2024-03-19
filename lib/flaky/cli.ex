defmodule Flaky.CLI do
  @moduledoc """
  The command line interface for Flaky.
  """

  alias Flaky.SynchronousTests

  defdelegate puts(string), to: IO
  defdelegate write(string), to: IO

  if Mix.env() == :test do
    @default_max_tests 2
  else
    @default_max_tests 100
  end

  def main(args \\ []) do
    case parse_args(args) do
      {:ok, parsed} ->
        puts("Starting tests...")
        test(parsed)

      {:error, _invalid} = error ->
        print_usage()

        error
    end
  end

  defp parse_args(args) do
    case OptionParser.parse(
           args,
           strict: [
             app_dir: :string,
             filename: :string,
             ignore_all_except: :string,
             line: :integer,
             max_tests: :integer,
             seed: :integer,
             test_path: :string
           ]
         ) do
      {parsed, _argv, [] = _invalid} ->
        {:ok, parsed}

      {_parsed, _argv, invalid} ->
        {:error, invalid}
    end
  end

  defp print_usage do
    puts("""
    Usage:
      flaky [options]

    Options:
      --app_dir, -a           Absolute path to the app dir to test with.
      --filename, -f          Filename to test. Only used when app_dir is set.
      --ignore_all_except, -i String or list of strings to treat as a test failure.
      --line, -l              Line number to test. Only used when filename is set.
      --max_tests, -m         Max tests to run. Default is #{@default_max_tests}.
      --seed, -s              Seed to use instead of a random one.
      --test_path, -t         Relative path from app dir to the dir to test. Default is "test".
    """)
  end

  defp get_progress(count) do
    if Integer.mod(count, 10) == 0, do: count, else: "."
  end

  defp test(opts, count \\ 1) do
    case SynchronousTests.perform(opts) do
      {:error, output} = error ->
        puts("\n\nTest failed!\n\n#{inspect(output)}")

        error

      {result, output} ->
        new_count = count + 1
        max_tests = Keyword.get(opts, :max_tests, @default_max_tests)

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
