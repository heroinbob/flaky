defmodule Flaky.Printer do
  @moduledoc """
  An API our app can use to desplay messages and errors regardless of the context.

  By default it relies on `IO` but is also compatible with `Mix.Shell.IO`
  """

  @doc """
  Prints an informational message.
  """
  @spec print_info(String.t(), atom()) :: term()
  def print_info(message, io_source \\ IO)

  def print_info(message, IO = io_source), do: io_source.puts(message)
  def print_info(message, Mix.Shell.IO = io_source), do: io_source.info(message)

  @doc """
  Prints an error message. This shows up in red when possible.
  """
  @spec print_error(String.t(), atom()) :: term()
  def print_error(message, io_source \\ IO)

  def print_error(message, IO = io_source) do
    io_source.puts(IO.ANSI.red() <> message)
  end

  def print_error(message, Mix.Shell.IO = io_source), do: io_source.error(message)

  @doc """
  Print the given line exactly with no additional newline, if possible.
  """
  @spec print_line(String.t(), atom()) :: term()
  def print_line(line, io_source \\ IO)

  def print_line(line, IO = io_source), do: io_source.write(line)
  def print_line(line, Mix.Shell.IO = io_source), do: io_source.info(line)
end
