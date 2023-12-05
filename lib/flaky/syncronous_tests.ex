defmodule Flaky.SynchronousTests do
  @doc """
  Runs the test as an asynchronous Task.

  ## Options
  - `filename` - Optional filename to test.
  - `line` - Optional line number to test. Only used when filename is set.
  - `seed` - Optional seed to use instead of a random one.
  - `test_path` - Required relative path from app dir to the dir to test.
  """
  def perform(opts) do
    # IO.inspect({"OPTS", opts})
    filename = Keyword.get(opts, :filename) || :no_filename
    line = Keyword.get(opts, :line) || :no_line
    seed = Keyword.get(opts, :seed) || :default
    test_path = Keyword.get(opts, :test_path) || :no_test_path

    filename
    |> maybe_filter(line, test_path)
    |> maybe_seed(seed)
    |> run_mix_command(opts)
  end

  defp maybe_filter(_filename, _line, :no_test_path), do: [""]
  defp maybe_filter(:no_filename, _line, test_path), do: [test_path]
  defp maybe_filter(filename, :no_line, test_path), do: ["#{test_path}/#{filename}"]
  defp maybe_filter(filename, line, test_path), do: ["#{test_path}/#{filename}:#{line}"]

  defp maybe_seed(args, :default), do: args
  defp maybe_seed(args, seed), do: ["--seed", inspect(seed) | args]

  defp run_mix_command(args, opts) do
    app_dir = Keyword.fetch!(opts, :app_dir)
    exceptions = coerce_exceptions(opts)

    File.cd!(app_dir)
    {output, exit_code} = System.cmd("mix", ["test" | args])

    # Can't rely on exit code alone. If the file isn't found for example it still
    # returns a 0 exit code. We accounted for that during startup but in a nutshell
    # be really really sure it ran successfully.
    result =
      cond do
        exit_code == 0 and String.contains?(output, " 0 failures") ->
          :ok

        is_list(exceptions) and not String.contains?(output, exceptions) ->
          :ignored

        true ->
          :error
      end

    {result, output}
  end

  defp coerce_exceptions(opts) do
    ignore_all_except = Keyword.get(opts, :ignore_all_except, :none)
    if is_binary(ignore_all_except), do: [ignore_all_except], else: ignore_all_except
  end
end
