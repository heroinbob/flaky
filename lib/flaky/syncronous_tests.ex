defmodule Flaky.SynchronousTests do
  @doc """
  Runs a mix command using the given options.

  ## Options
  - `:app_dir` - Required absolute path to the app dir to test.
  - `:filename` - Optional filename to test.
  - `:ignore_all_except` - String or list of strings to treat as a test failure. Tests
                           can fail in the run and will be ignored unless any value given
                          for this option is present in the output.
  - `:line` - Optional line number to test. Only used when filename is set.
  - `:seed` - Optional seed to use instead of a random one.
  - `:test_path` - Optional relative path from app dir to the dir to test. Default is `"test"`.
  """
  def perform(opts) do
    filename = Keyword.get(opts, :filename, :no_filename)
    line = Keyword.get(opts, :line, :no_line)
    seed = Keyword.get(opts, :seed, :default)
    test_path = Keyword.get(opts, :test_path, "test")

    filename
    |> maybe_filter(line, test_path)
    |> maybe_seed(seed)
    |> run_mix_command(opts)
  end

  defp maybe_filter(:no_filename, _line, test_path), do: [test_path]
  defp maybe_filter(filename, :no_line, test_path), do: ["#{test_path}/#{filename}"]
  defp maybe_filter(filename, line, test_path), do: ["#{test_path}/#{filename}:#{line}"]

  defp maybe_seed(args, :default), do: args
  defp maybe_seed(args, seed), do: ["--seed", inspect(seed) | args]

  defp run_mix_command(args, opts) do
    exceptions = coerce_exceptions(opts)

    # Use the :cd option instead of File.cd! so you don't change the beam global
    # working directory.
    {output, exit_code} =
      System.cmd(
        "mix",
        ["test" | args],
        cd: Keyword.fetch!(opts, :app_dir)
      )

    # Can't rely on exit code alone. If the file isn't found for example it still
    # returns a 0 exit code. We accounted for that during startup but in a nutshell
    # be really really sure it ran successfully.
    cond do
      exit_code == 0 and String.contains?(output, " 0 failures") ->
        {:ok, output}

      is_list(exceptions) and not String.contains?(output, exceptions) ->
        {:ok, {:ignored, output}}

      true ->
        {:error, {exit_code, output}}
    end
  end

  defp coerce_exceptions(opts) do
    ignore_all_except = Keyword.get(opts, :ignore_all_except, :none)
    if is_binary(ignore_all_except), do: [ignore_all_except], else: ignore_all_except
  end
end
