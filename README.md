# Phoenix.Slack

Use Slack to easily send emails in your Phoenix project.

This module provides the ability to set the HTML and/or text body of an email by rendering templates.

See the [docs](http://hexdocs.pm/phoenix_slack) for more information.

## Installation

  1. Add phoenix_slack to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:phoenix_slack, "~> 0.1"}]
end
```

  2. (Optional - only for Elixir < 1.4) Ensure phoenix_slack is started before your application:

```elixir
def application do
  [applications: [:phoenix_slack]]
end
```

## Documentation

Documentation is written into the library, you will find it in the source code, accessible from `iex` and of course, it
all gets published to [hexdocs](http://hexdocs.pm/phoenix_slack).

## Contributing

### Running tests

Clone the repo and fetch its dependencies:

```
$ git clone https://github.com/sitch/phoenix_slack.git
$ cd phoenix_slack
$ mix deps.get
$ mix test
```

### Building docs

```
$ MIX_ENV=docs mix docs
```

## LICENSE

See [LICENSE](https://github.com/sitch/phoenix_slack/blob/master/LICENSE.txt)
