defmodule Mix.Tasks.Flaky.Test do
  @moduledoc """
  Run tests and find the flaky one.

  `mix flaky.test [options]`

  ## Options

  -a, --app - The app to run tests for. Required for an umbrella app.

  -i, --ignore_all_except - String or list of strings to treat as a test failure.

  -m, --max_tests - Max tests to run. Default: #{Flaky.Options.default_max_tests()}

  -s, --seed - Seed to use instead of a random one.

  -t, --test-path - The relative path to the test folder for the app. Default: "test"
  """
  use Mix.Task

  import Flaky.Printer

  alias Mix.Tasks.Flaky.Test.Options

  @shortdoc "Run tests and return the first failing one."

  @impl Mix.Task
  def run(args) do
    opts = Options.from_argv(args)

    app_path =
      if Mix.Project.umbrella?() do
        if is_nil(opts.app), do: print_usage_and_exit("--app is required for umbrella apps")

        app = String.to_existing_atom(opts.app)
        Map.fetch!(Mix.Project.apps_paths(), app)
      else
        Mix.Project.app_path()
      end

    app_path = Path.expand(app_path)

    Flaky.test(%Flaky.Options{
      app_dir: app_path,
      ignore_all_except: opts.ignore_all_except,
      max_tests: opts.max_tests,
      seed: opts.seed,
      test_path: opts.test_path
    })
  end

  defp print_usage_and_exit(error) do
    print_error(error, io_source())

    print_info(
      """
      -a, --app - The app to run tests for. Required for an umbrella app.
      -i, --ignore_all_except - String or list of strings to treat as a test failure.
      -m, --max_tests - Max tests to run. Default: #{Flaky.Options.default_max_tests()}
      -s, --seed - Seed to use instead of a random one.
      -t, --test-path - The relative path to the test folder for the app. Default: "test"
      """,
      io_source()
    )

    exit(1)
  end

  defp io_source, do: Mix.shell()
end
