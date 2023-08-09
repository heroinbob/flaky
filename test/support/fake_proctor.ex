defmodule Flaky.Test.Suppost.FakeProctor do
  @moduledoc """
  GenServer that acts as a standin for tests that need to interact with the
  Proctor.
  """
  use GenServer

  alias Flaky.Tests

  @server_name :test_proctor
  def server_name, do: @server_name

  defstruct app_dir: nil,
            concurrency: 2,
            num_passed: 0,
            max_tests: 100,
            opts: [],
            status: :idle,
            time_started: nil

  def init(state), do: {:ok, state}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, opts)
  end

  @doc """
  Returns true if the proctor is currently running tests.
  """
  def testing?, do: GenServer.call(@server_name, :testing?)

  @doc """
  Starts the tests and tracking.
  """
  @spec start_tests(keyword()) :: :ok | {:error, :already_running}
  def start_tests(opts) do
    GenServer.call(@server_name, {:start_tests, opts})
  end

  def test_failed(output), do: GenServer.cast(@server_name, {:test_failed, output})
  def test_passed, do: GenServer.cast(@server_name, :test_passed)

  def handle_call(
        {:start_tests, _test_name},
        _from,
        %{status: :running} = state
      ) do
    {
      :reply,
      {:error, :already_running},
      state
    }
  end

  def handle_call({:start_tests, opts}, _from, %{status: :idle} = state) do
    app_dir = Keyword.get(opts, :app_dir, "no app dir specified")
    concurrency = Keyword.get(opts, :concurrency, 2)
    filename = Keyword.get(opts, :filename, "no file specified")
    max_tests = Keyword.get(opts, :max_tests, 100)
    test_path = Keyword.get(opts, :test_path, "no path specified")

    IO.inspect({
      "Starting tests",
      "app dir: ",
      app_dir,
      "filename: ",
      filename,
      "concurrency: ",
      concurrency,
      "max tests: ",
      max_tests,
      "test path",
      test_path
    })

    for _ <- 1..concurrency do
      {:ok, pid} = Tests.perform(opts)
      pid
    end

    {
      :reply,
      :ok,
      %{
        state
        | app_dir: app_dir,
          concurrency: concurrency,
          max_tests: max_tests,
          num_passed: 0,
          opts: opts,
          status: :running,
          time_started: DateTime.utc_now()
      }
    }
  end

  def handle_call(:testing?, _from, %{status: :running} = state), do: {:reply, true, state}
  def handle_call(:testing?, _from, state), do: {:reply, false, state}

  def handle_cast({:test_failed, output}, state) do
    Tests.cancel()
    IO.puts("\nFailed!")
    IO.puts(output)

    {:noreply, %{state | status: :idle}}
  end

  def handle_cast(
        :test_passed,
        %{
          max_tests: max_tests,
          num_passed: num_passed,
          time_started: time_started
        } = state
      )
      when num_passed + 1 == max_tests do
    IO.inspect({"Finished in", DateTime.diff(DateTime.utc_now(), time_started), "seconds"})
    {:noreply, %{state | status: :idle}}
  end

  def handle_cast(
        :test_passed,
        %{num_passed: num_passed, opts: opts} = state
      ) do
    Tests.perform(opts)
    output = if :erlang.rem(num_passed, 10) == 0, do: num_passed, else: "."
    IO.write(output)

    {:noreply, %{state | num_passed: num_passed + 1}}
  end
end
