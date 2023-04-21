defmodule Flaky.Proctor do
  @moduledoc """
  GenServer that manages the tests and reports the results.

  One server is run when the app is started. It maintains state and tracks the
  test processes.
  """
  use GenServer

  alias Flaky.Tests

  @server_name :proctor
  def server_name, do: @server_name

  defstruct concurrency: 2,
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
    concurrency = Keyword.get(opts, :concurrency, 2)
    filename = Keyword.get(opts, :filename, "no file specified")
    max_tests = Keyword.get(opts, :max_tests, 100)
    test_path = Keyword.get(opts, :test_path, "no path specified")

    IO.inspect({
      "Starting tests",
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
        | concurrency: concurrency,
          max_tests: max_tests,
          num_passed: 0,
          opts: opts,
          status: :running,
          time_started: DateTime.utc_now()
      }
    }
  end

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
