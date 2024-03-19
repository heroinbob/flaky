# Flaky

A simple app to help find a flaky test in your elixir app.

## Usage
This provides a CLI interface using escript for your convenience.
You can invoke a single test, a group of tests, a whole file or the entire suite.

`flaky [options]`

Options:

--app_dir, -a           Absolute path to the app dir to test with.
--filename, -f          Filename to test. Only used when app_dir is set.
--ignore_all_except, -i String or list of strings to treat as a test failure.
--line, -l              Line number to test. Only used when filename is set.
--max_tests, -m         Max tests to run. Default is #{Flaky.Options.default_max_tests()}.
--seed, -s              Seed to use instead of a random one.
--test_path, -t         Relative path from app dir to the dir to test. Default is "test".

## Examples

    flaky --app_dir: "/home/billy/my_app" --filename "demo_test.exs" --line: 420 --test_path "test/thing"
    flaky --app_dir: "/home/billy/my_app" --filename "demo_test.exs" --test_path "test/thing"
    flaky --app-dir: "/home/billy/my_app" --test_path "test/thing"
    flaky --app-dir: "/home/billy/my_app" --test_path "test"

## Installation

Clone the repo on your machine, and go for it! This has an asdf tools file so you
can install deps that way if you're inclined

Then run `mix escript.install` and then `mix.escript.build`. If all went well you now have the executable
file `flaky` at the root of the project.
