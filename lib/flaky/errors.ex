defmodule Flaky.Errors do
  def from_test_output(output) do
    output
    |> String.split("\n")
    |> Enum.reduce(
      %{buffer: [], errors: [], is_capturing: false},
      fn
        line, %{buffer: buffer, errors: errors, is_capturing: true} = acc ->
          # Once the error output is done it runs another test
          # TODO: what does consecutive errors look like? We need a way to flush
          # and THEN trigger another check to see if this line is also part of
          # an error
          if String.starts_with?(line, ".") do
            %{
              acc
              | buffer: [],
                errors: flush_buffer(buffer, errors),
                is_capturing: false
            }
          else
            %{acc | buffer: [line | buffer]}
          end

        line, acc ->
          # Line with a fail starts with "  N)"
          if line =~ ~r/^  \d+\)/ do
            IO.inspect({"FOUND ERROR...", line})
            %{acc | buffer: [line], is_capturing: true}
          else
            acc
          end
      end
    )
    |> then(fn
      %{buffer: buffer, errors: errors, is_capturing: true} ->
        flush_buffer(buffer, errors)

      %{errors: errors} ->
        errors
    end)
  end

  defp flush_buffer(buffer, errors), do: [buffer |> Enum.reverse() |> Enum.join("\n") | errors]
end
