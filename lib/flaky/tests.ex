defmodule Flaky.Tests do
  alias Flaky.Proctor
  alias Flaky.TestSupervisor

  @doc """
  Cancels all running tests.
  """
  def cancel do
    # TODO: Add verbosity!
    IO.puts("\nCANCELLING!")

    TestSupervisor
    |> Task.Supervisor.children()
    |> Enum.each(fn pid ->
      IO.inspect({"Stopping test", pid})
      Task.Supervisor.terminate_child(TestSupervisor, pid)
    end)
  end

  @doc """
  Runs the test as an asynchronous Task.

  ## Options
  - `filename` - Optional filename to test.
  - `line` - Optional line number to test. Only used when filename is set.
  - `seed` - Optional seed to use instead of a random one.
  - `test_path` - Required relative path from app dir to the dir to test.
  """
  def perform(opts, proctor \\ Proctor) do
    # IO.inspect({"OPTS", opts})
    app_dir = Keyword.fetch!(opts, :app_dir)
    filename = Keyword.get(opts, :filename) || :no_filename
    line = Keyword.get(opts, :line) || :no_line
    seed = Keyword.get(opts, :seed) || :default
    test_path = Keyword.get(opts, :test_path) || :no_test_path

    ###
    # Well we have a problem - when the app needs to be compiled we run into a
    # race condition - so we need to be sure to compile the app prior to running
    # a test!
    ###
    # File.cd!(app_dir)
    # System.cmd("elixir", ["--version"]) |> IO.inspect()
    ###

    filename
    |> maybe_filter(line, test_path)
    |> maybe_seed(seed)
    |> then(&["test" | &1])
    |> run_mix_command(app_dir, proctor)
  end

  defp maybe_filter(_filename, _line, :no_test_path), do: [""]
  defp maybe_filter(:no_filename, _line, test_path), do: [test_path]
  defp maybe_filter(filename, :no_line, test_path), do: ["#{test_path}/#{filename}"]
  defp maybe_filter(filename, line, test_path), do: ["#{test_path}/#{filename}:#{line}"]

  defp maybe_seed(args, :default), do: args
  defp maybe_seed(args, seed), do: ["--seed", inspect(seed) | args]

  defp run_mix_command(args, app_dir, proctor) do
    Task.Supervisor.start_child(
      TestSupervisor,
      fn ->
        File.cd!(app_dir)

        "mix"
        |> System.cmd(args)
        |> passed?()
        |> handle_result(proctor)
      end
    )
  end

  defp handle_result({true, _output}, proctor) do
    # IO.puts(_output)
    proctor.test_passed()
  end

  defp handle_result({false, output}, proctor), do: proctor.test_failed(output)

  # Can't rely on exit code alone. If the file isn't found for example it still
  # returns a 0 exit code. We accounted for that during startup but in a nutshell
  # be really really sure it ran successfully.
  defp passed?({output, 0}), do: {String.contains?(output, " 0 failures"), output}
  defp passed?({output, _not_zero}), do: {false, output}
end
