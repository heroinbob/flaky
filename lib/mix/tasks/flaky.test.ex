defmodule Mix.Tasks.Flaky.Test do
  @moduledoc """
  Run tests and find the flaky one.
  """
  use Mix.Task

  @shortdoc "Run tests and return the first failing one"

  @aliases [
    a: :app,
    f: :filename,
    i: :ignore_all_except,
    l: :line,
    m: :max_tests,
    s: :seed,
    t: :test_path
  ]

  @switches [
    app: :string,
    filename: :string,
    ignore_all_except: :string,
    line: :integer,
    max_tests: :integer,
    seed: :integer,
    test_path: :string
  ]

  @impl true
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    filename = Keyword.get(opts, :filename)
    line = Keyword.get(opts, :line)
    test_path = Keyword.get(opts, :test_path, "test")

    app_path =
      if Mix.Project.umbrella?() do
        app = Keyword.get(opts, :app) || print_usage("--app is required for umbrella apps")
        app = String.to_existing_atom(app)
        Map.fetch!(Mix.Project.apps_paths(), app)
      else
        Mix.Project.app_path()
      end

    app_path = Path.expand(app_path)

    Mix.shell().info("TODO #{inspect([app_path, filename, line, test_path])}")
    Mix.Flaky.flakinate()

    :ok =
      Flaky.test(
        app_dir: app_path,
        filename: filename,
        line: line,
        test_path: test_path
      )

    continue()
  end

  defp print_usage(error) do
    Mix.shell().error(error)

    Mix.shell().info("""
    -a, --app - The app to run tests for. Required for an umbrella app.
    -f, --filename - Narrow the scope to a single file (optional)
    -i, --ignore_all_except - String or list of strings to treat as a test failure.
    -l, --line - Narrow the scope to a line in the file (optional)
    -m, --max_tests - Max tests to run. Default: #{@default_max_tests}
    -s, --seed - Seed to use instead of a random one.
    -t, --test-path - The relative path to the test folder for the app. Default: "test"
    """)

    exit(1)
  end

  defp continue do
    Process.sleep(1000)

    if Flaky.testing?() do
      continue()
    else
      Mix.shell().info("Done")
    end
  end
end
