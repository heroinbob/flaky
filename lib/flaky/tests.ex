defmodule Flaky.Tests do
  alias Flaky.Proctor
  alias Flaky.TestSupervisor

  def cancel do
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
  - `test_path` - Required relative path from app dir to the dir to test.
  """
  def perform(opts) do
    command_arg =
      get_command_arg(
        Keyword.get(opts, :filename, :no_filename),
        Keyword.get(opts, :line, :no_line),
        Keyword.get(opts, :test_path, :no_test_path)
      )

    Task.Supervisor.start_child(
      TestSupervisor,
      fn ->
        opts |> Keyword.fetch!(:app_dir) |> File.cd!()

        "mix"
        |> System.cmd(["test", command_arg])
        |> passed?()
        |> handle_result()
      end
    )
  end

  defp get_command_arg(_filename, _line, :no_test_path), do: ""
  defp get_command_arg(:no_filename, _line, test_path), do: test_path
  defp get_command_arg(filename, :no_line, test_path), do: "#{test_path}/#{filename}"
  defp get_command_arg(filename, line, test_path), do: "#{test_path}/#{filename}:#{line}"

  defp handle_result({true, _output}) do
    # IO.puts(_output)
    Proctor.test_passed()
  end

  defp handle_result({false, output}), do: Proctor.test_failed(output)

  # Can't rely on exit code alone. If the file isn't found for example it still
  # returns a 0 exit code. We accounted for that during startup but in a nutshell
  # be really really sure it ran successfully.
  defp passed?({output, 0}), do: {String.contains?(output, " 0 failures"), output}
  defp passed?({output, _not_zero}), do: {false, output}
end
