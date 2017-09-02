defmodule PhoenixSlack.Mixfile do
  use Mix.Project

  @version "0.1.0"

  @repo "https://github.com/sitch/phoenix_slack"

  def project do
    [app: :phoenix_slack,
     version: @version,
     elixir: "~> 1.4",
     compilers: compilers(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     # Hex
     description: description(),
     package: package(),

     # Docs
     name: "Phoenix.Slack",
     docs: [source_ref: "v#{@version}", main: "Phoenix.Slack",
            canonical: "http://hexdocs.pm/phoenix_slack",
            source_url: @repo]]     
  end

  defp compilers(:test), do: [:phoenix] ++ Mix.compilers
  defp compilers(_), do: Mix.compilers

  def application do
    [applications: [:logger, :slack]]
  end

  defp deps do
    [{:slack, "~> 0.11"},
     {:phoenix, "~> 1.0"},
     {:phoenix_html, "~> 2.2"},
     {:credo, "~> 0.8", only: [:dev, :test]},
     {:mix_test_watch, "~> 0.2", only: :dev, runtime: false},
     {:ex_doc, "~> 0.16", only: :docs},
     {:inch_ex, ">= 0.0.0", only: :docs}]
  end

  defp description do
    """
    Use Slack to easily send messages in your Phoenix project.
    """
  end

  defp package do
    [maintainers: ["Michael Sitchenko"],
     licenses: ["MIT"],
     links: %{"GitHub" => @repo}]
  end
end
