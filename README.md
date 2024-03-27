# Flaky

A simple app to help find a flaky test in your elixir app.

## Installation

The simplest way is to add the dependency to your `mix.exs` file. Then get deps and try it out.

```elixir
defp deps do
    [{:flaky, path: "~> 0.1.0"}]
end
```

You can now execute the mix task `mix flaky.test` which will execute tests in your app.
To see all the options and some examples run `mix help flaky.test`.

## Development and Testing

If you'd like to contribute or experiment then you'll need to install the deps. When testing
you'll want to exclude anything with the `fake_tests` tag. These are apps with tests designed
to be run to verify the various flaky features.

```bash
asdf install
mix deps.get
mix test --exclude fake_tests
```
