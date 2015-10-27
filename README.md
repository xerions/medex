# Medex [![Build Status](https://travis-ci.org/xerions/medex.svg)](https://travis-ci.org/xerions/medex)

Medical Examination - application for register health check callbacks and represent their state via HTTP.

## Installation

1. Add medex to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:medex, github: "xerions/medex"}]
    end
    ```

2. Ensure medex is started before your application:

    ```elixir
    def application do
      [applications: [:medex]]
    end
    ```


## Example

Register new check callback:

```elixir
Medex.register "db", fn() ->
    case :erlang.phash2(:erlang.now, 3) do
      0 -> :ok
      1 -> :warning
      2 -> :critical
    end
  end
```

and get state

    $ curl -v http://localhost:4000/health/db
