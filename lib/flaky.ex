defmodule Flaky do
  import Flaky.Printer

  alias Flaky.Options
  alias Flaky.SynchronousTests
  alias Mix.Tasks.Flaky.Test.Options, as: MixOptions

  @doc """
  Execute tests until failure or max_tests is reached using the given options.
  """
  @spec test(Options.t() | MixOptions.t(), non_neg_integer(), any()) :: :ok
  def test(%mod{max_tests: max_tests} = opts, count \\ 1, io_source \\ IO)
      when mod in [MixOptions, Options] do
    case SynchronousTests.perform(opts) do
      {:error, output} = error ->
        print_error("\n\nTest failed!\n\n#{inspect(output)}", io_source)

        error

      {:ok, {:ignored, output}} ->
        new_count = count + 1

        if new_count <= max_tests do
          print_info("\nFailure ignored:\n\n#{output}")
          test(opts, new_count)
        else
          print_info("\nMax tests has been reached. Nothing was flaky!")
          :ok
        end

      {:ok, output} ->
        new_count = count + 1

        cond do
          count == 1 ->
            # Always print first test results. This allows one to compare a good run against
            # a bad run with any debug values being printed out.
            print_info("First test passed:\n\n#{output}")
            test(opts, new_count)

          new_count <= max_tests ->
            count |> get_progress() |> print_line()
            test(opts, new_count)

          true ->
            print_info("\nMax tests has been reached. Nothing was flaky!")
            :ok
        end
    end
  end

  defp get_progress(count) do
    if Integer.mod(count, 10) == 0, do: count, else: "."
  end
end
