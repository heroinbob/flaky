defmodule Flaky do
  alias Flaky.Proctor

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
    * :line - [Optional] The line number of the scope for the test.
    * :max_tests - [Optional] The max number of tests to run successfully before stopping. Default 100.
    * :test_path - [Optional] The relative path for the test file.
  """
  @spec test(keyword()) :: :ok | {:error, :already_running}
  def test(opts) do
    opts |> check_opts() |> Proctor.start_tests()
    :ok
  end

  defp check_opts(opts) do
    app_dir = Keyword.get(opts, :app_dir)
    filename = Keyword.get(opts, :filename)
    test_path = Keyword.get(opts, :test_path)

    if is_nil(app_dir), do: raise(ArgumentError, "You must provide :app_dir option")

    if test_path && filename do
      File.cd!(app_dir <> "/" <> test_path)
      unless File.exists?(filename), do: raise(ArgumentError, "file does not exist!")
    end

    opts
  end
end
