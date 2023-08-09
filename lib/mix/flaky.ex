defmodule Mix.Flaky do
  def flakinate do
    #    apps =
    #      if Mix.Project.umbrella?() do
    #        apps_paths |> Map.keys() |> Enum.sort()
    #      else
    #        [Mix.Project.config()[:app]]
    #      end

    Flaky.Application.start(nil, nil)
    # Application.load(:flaky)
    # Application.get_env(app, :ecto_repos, [])
  end
end
