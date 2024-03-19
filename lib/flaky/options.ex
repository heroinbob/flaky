defmodule Flaky.Options do
  @moduledoc """
  Parser and validator for Flaky options.
  """

  if Mix.env() == :test do
    @default_max_tests 2
  else
    @default_max_tests 100
  end

  defstruct [
    :app_dir,
    :filename,
    :ignore_all_except,
    :line,
    :seed,
    :test_path,
    max_tests: @default_max_tests
  ]

  @type t() :: %__MODULE__{
          app_dir: String.t(),
          filename: String.t() | nil,
          ignore_all_except: String.t() | [String.t()] | nil,
          line: non_neg_integer() | nil,
          max_tests: non_neg_integer() | nil,
          seed: integer() | nil,
          test_path: String.t()
        }

  def default_max_tests, do: @default_max_tests

  @aliases [
    a: :app_dir,
    f: :filename,
    i: :ignore_all_except,
    l: :line,
    m: :max_tests,
    s: :seed,
    t: :test_path
  ]

  @switches [
    app_dir: :string,
    filename: :string,
    ignore_all_except: :string,
    line: :integer,
    max_tests: :integer,
    seed: :integer,
    test_path: :string
  ]

  @doc """
  Parses the command line arguments.
  """
  @spec from_argv([String.t()]) :: map()
  def from_argv(argv) do
    {opts, _} = OptionParser.parse!(argv, strict: @switches, aliases: @aliases)

    %__MODULE__{
      app_dir: Keyword.fetch!(opts, :app_dir),
      filename: Keyword.get(opts, :filename),
      ignore_all_except: Keyword.get(opts, :ignore_all_except),
      line: Keyword.get(opts, :line),
      max_tests: Keyword.get(opts, :max_tests, @default_max_tests),
      seed: Keyword.get(opts, :seed),
      test_path: Keyword.get(opts, :test_path, "test")
    }
  end
end
