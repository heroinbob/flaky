defmodule Flaky.SynchronousTests do
  alias Flaky.Options

  @doc """
  Runs a mix command using the given options.
  """
  def perform(
        %Options{
          filename: filename,
          line: line,
          seed: seed,
          test_path: test_path
        } = opts
      ) do
    filename
    |> maybe_filter(line, test_path)
    |> maybe_seed(seed)
    |> run_mix_command(opts)
  end

  defp maybe_filter(nil = _filename, _line, test_path), do: [test_path]
  defp maybe_filter(filename, nil = _line, test_path), do: ["#{test_path}/#{filename}"]
  defp maybe_filter(filename, line, test_path), do: ["#{test_path}/#{filename}:#{line}"]

  defp maybe_seed(args, nil = _seed), do: args
  defp maybe_seed(args, seed), do: ["--seed", inspect(seed) | args]

  defp run_mix_command(args, %{app_dir: app_dir} = opts) do
    exceptions = coerce_exceptions(opts)

    # Use the :cd option instead of File.cd! so you don't change the beam global
    # working directory.
    {output, exit_code} =
      System.cmd(
        "mix",
        ["test" | args],
        cd: app_dir
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

  defp coerce_exceptions(%{ignore_all_except: exceptions}) when is_binary(exceptions) do
    [exceptions]
  end

  defp coerce_exceptions(%{ignore_all_except: exceptions}), do: exceptions
end
