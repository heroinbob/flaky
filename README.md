# Flaky

A simple app to help find a flaky test in your elixir app.

## Usage
You can invoke a single test, a group of tests, a whole file or the entire suite.

    iex(1)> Flaky.test(app_dir: "/home/billy/my_app", filename: "demo_test.exs", line: 420, test_path: "test/thing")
    iex(3)> Flaky.test(app_dir: "/home/billy/my_app", filename: "demo_test.exs", test_path: "test/thing")
    iex(5)> Flaky.test(app_dir: "/home/billy/my_app", test_path: "test/thing")
    iex(7)> Flaky.test(app_dir: "/home/billy/my_app", test_path: "test")

## Installation

Clone the repo on your machine, and go for it! This has an asdf tools file so you
can install deps that way if you're inclined
