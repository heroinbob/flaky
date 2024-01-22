defmodule Flaky.CLI do
  alias Flaky.SynchronousTests

  defdelegate puts(string), to: IO
  defdelegate write(string), to: IO

  @doc """

  """
  def main(args \\ []) do
    case parse_args(args) do
      {:ok, parsed} ->
        puts("Starting tests...")
        test(parsed)

      {:error, invalid} ->
        IO.inspect(invalid)
        print_usage()
    end
  end

  defp parse_args(args) do
    case OptionParser.parse(
           args,
           strict: [
             app_dir: :string,
             filename: :string,
             ignore_all_except: :string,
             line_number: :integer,
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
    TODO
    """)
  end

  defp get_progress(count) do
    if Integer.mod(count, 10) == 0, do: count, else: "."
  end

  defp test(opts, count \\ 1) do
    case SynchronousTests.perform(opts) do
      {:error, output} ->
        puts("\n\nTest failed!")
        puts(output)

      {result, output} ->
        new_count = count + 1
        max_tests = Keyword.get(opts, :max_tests, 100)

        cond do
          count == 1 ->
            puts("First test passed:\n\n#{output}")
            test(opts, new_count)

          new_count <= max_tests ->
            if result == :ignored do
              puts("\nFailure ignored:\n\n#{output}")
            end

            count |> get_progress() |> write()
            test(opts, new_count)

          true ->
            puts("\nMax tests has been reached. Nothing was flaky!")
        end
    end
  end
end
