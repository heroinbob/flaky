defmodule Flaky do
  alias Flaky.Errors
  alias Flaky.Proctor

  defdelegate stop_tests, to: Proctor
  defdelegate testing?, to: Proctor

  @doc """
  Starts asynchronous tests using the given name. the name should be a relative
  path based on the root of the product you're testing.

  By default all the tests for the given file are run. To isolate a test or a
  group of tests, use the `:line` option.

  Raises ArgumentError if app_dir or name is not provided.

  opts:
    * :app_dir - [Required] The absolute path to the root of the app you're testing.
    * :concurrency - [Optional] The number of tests to run at the same time. Default: 2.
    * :filename - [Optional] The name of the file to test.
    * :ignore_all_except - [Optional] All test failures are ignored unless the given values are present.
    * :line - [Optional] The line number of the scope for the test.
    * :max_tests - [Optional] The max number of tests to run successfully before stopping. Default 100.
    * :seed - [Optional] The seed to use for randomizing the tests.
    * :test_path - [Optional] The relative path for the test file.
  """
  @spec test(keyword()) ::
          {:ok, :testing}
          | {:error, :already_running}
          | {:error, {:compile_failed, {String.t(), non_neg_integer()}}}
  def test(opts) do
    opts
    |> check_opts()
    |> compile()
    |> Proctor.start_tests()

    # IO.puts("compiling again...")
    # {_stream, 0} = System.shell("mix compile", into: IO.stream())
  end

  def test_experimental(opts) do
    opts = Keyword.put_new(opts, :app_dir, Application.get_env(:flaky, :app_dir))
    opts |> check_opts() |> compile()

    max_tests = Keyword.get(opts, :max_tests, 100)
    IO.puts("Compilation Done. Running #{max_tests} tests.")

    for number <- 1..max_tests do
      # TODO - betterify
      case Flaky.SynchronousTests.perform(opts) do
        {:ok, output} ->
          if number == 1 do
            IO.puts("First passed.\n\n#{output}")
          else
            # IO.write(".")
            IO.puts("Run #{number} passed")
          end

        {:ignored, output} ->
          # IO.write(".")
          errors = Errors.from_test_output(output)

          IO.puts("\n#{Enum.join(errors, "\n====\n")}\n\nRun #{number} failed, but ignored.")

        {:error, output} ->
          raise RuntimeError, "\n#{output}\n\nTest#{number} Failed! Output is above."
      end
    end

    IO.puts("All tests passed.")
  end

  # TODO: this is validation.
  defp check_opts(opts) do
    app_dir = Keyword.get(opts, :app_dir)
    filename = Keyword.get(opts, :filename)
    test_path = Keyword.get(opts, :test_path)

    if is_nil(app_dir), do: raise(ArgumentError, "You must provide :app_dir option")

    case (app_dir <> "/" <> test_path) |> File.cd() do
      {:error, reason} ->
        raise(ArgumentError, ~s(test path "#{app_dir <> "/" <> test_path}" is invalid: #{reason}))

      :ok ->
        :ok
    end

    if filename do
      unless File.exists?(filename), do: raise(ArgumentError, "file does not exist!")
    end

    opts
  end

  defp compile(opts) do
    # app_dir = Keyword.get(opts, :app_dir)

    IO.puts("Compiling, one moment...")
    opts |> Keyword.get(:app_dir) |> File.cd!()

    case System.cmd("mix", ["compile"], into: IO.stream()) do
      {_stream, 0} ->
        # IO.puts("done!")
        opts

      {_stream, code} ->
        raise(CompileError, "Compilation failed! #{inspect(code)}")
    end
  end
end
