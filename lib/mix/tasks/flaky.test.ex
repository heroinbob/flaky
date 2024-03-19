defmodule Mix.Tasks.Flaky.Test do
  @moduledoc """
  Run tests and find the flaky one.
  """
  use Mix.Task

  alias Flaky.Options
  alias Flaky.SynchronousTests

  @shortdoc "Run tests and return the first failing one"

  @impl true
  def run(args) do
    opts = Options.from_argv(args)

    # app_path =
    #   if Mix.Project.umbrella?() do
    #     # app = Keyword.get(opts, :app_dir) || print_usage("--app is required for umbrella apps")
    #     # app = String.to_existing_atom(app)
    #     # TODO: fix
    #     Map.fetch!(Mix.Project.apps_paths(), app_dir)
    #   else
    #     Mix.Project.app_path()
    #   end
    #
    # app_path = Path.expand(app_path)

    Mix.shell().info("TODO #{inspect(opts)}")
    test(opts)

    # :ok =
    #   Flaky.test(
    #     app_dir: app_path,
    #     filename: filename,
    #     line: line,
    #     test_path: test_path
    #   )
    #
    # continue()
  end

  # defp print_usage(error) do
  #   Mix.shell().error(error)
  #
  #   Mix.shell().info("""
  #   -a, --app - The app to run tests for. Required for an umbrella app.
  #   -f, --filename - Narrow the scope to a single file (optional)
  #   -i, --ignore_all_except - String or list of strings to treat as a test failure.
  #   -l, --line - Narrow the scope to a line in the file (optional)
  #   -m, --max_tests - Max tests to run. Default: #{@default_max_tests}
  #   -s, --seed - Seed to use instead of a random one.
  #   -t, --test-path - The relative path to the test folder for the app. Default: "test"
  #   """)
  #
  #   exit(1)
  # end

  defp test(%{max_tests: max_tests} = opts, count \\ 1) do
    case SynchronousTests.perform(opts) do
      {:error, output} = error ->
        Mix.shell().error("\n\nTest failed!\n\n#{inspect(output)}")

        error

      {result, output} ->
        new_count = count + 1

        cond do
          count == 1 ->
            Mix.shell().info("First test passed:\n\n#{output}")
            test(opts, new_count)

          new_count <= max_tests ->
            if result == :ignored, do: Mix.shell().info("\nFailure ignored:\n\n#{output}")

            count |> get_progress() |> Mix.shell().info()
            test(opts, new_count)

          true ->
            Mix.shell().info("\nMax tests has been reached. Nothing was flaky!")
            :ok
        end
    end
  end

  defp get_progress(count) do
    if Integer.mod(count, 10) == 0, do: count, else: "."
  end
end
