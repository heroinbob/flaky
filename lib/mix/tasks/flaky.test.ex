defmodule Mix.Tasks.Flaky.Test do
  @moduledoc """
  Create the storage for the given repository.

  The repositories to create are the ones specified under the
  `:ecto_repos` option in the current app configuration. However,
  if the `-r` option is given, it replaces the `:ecto_repos` config.

  Since Ecto tasks can only be executed once, if you need to create
  multiple repositories, set `:ecto_repos` accordingly or pass the `-r`
  flag multiple times.

  ## Examples

      $ mix ecto.create
      $ mix ecto.create -r Custom.Repo

  ## Command line options

    * `-r`, `--repo` - the repo to create
    * `--quiet` - do not log output
    * `--no-compile` - do not compile before creating
    * `--no-deps-check` - do not compile before creating

  """
  use Mix.Task

  @shortdoc "Run tests and return the first failing one"

  @aliases [
    a: :app,
    c: :concurrency,
    f: :filename,
    l: :line,
    t: :test_path
  ]

  @switches [
    app: :string,
    concurrency: :integer,
    filename: :string,
    line: :integer,
    test_path: :string
  ]

  @impl true
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    concurrency = Keyword.get(opts, :concurrency, 2)
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
        concurrency: concurrency,
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
    -c, --concurrency - Number of tests to run simultaneously. Default: 2
    -f, --filename - Narrow the scope to a single file (optional)
    -l, --line - Narrow the scope to a line in the file (optional)
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
