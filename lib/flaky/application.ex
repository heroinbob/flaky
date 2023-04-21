defmodule Flaky.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Flaky.TestSupervisor, stategy: :transient},
      {Flaky.Proctor, name: Flaky.Proctor.server_name(), strategy: :one_for_one}
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: Flaky.Supervisor
    )
  end
end
