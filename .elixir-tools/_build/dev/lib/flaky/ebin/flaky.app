{application,flaky,
             [{optional_applications,[]},
              {applications,[kernel,stdlib,elixir]},
              {description,"flaky"},
              {modules,['Elixir.Flaky','Elixir.Flaky.CLI',
                        'Elixir.Flaky.Options','Elixir.Flaky.Printer',
                        'Elixir.Flaky.SynchronousTests',
                        'Elixir.Mix.Tasks.Flaky.Test',
                        'Elixir.Mix.Tasks.Flaky.Test.Options']},
              {registered,[]},
              {vsn,"0.1.0"}]}.