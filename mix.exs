defmodule ModuleGenerator.Mixfile do
  use Mix.Project

  @name :module_generator
  @version "1.0.0"

  @deps [
    {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    # { :earmark, ">0.1.5" },                      
    # { :ex_doc,  "1.2.3", only: [ :dev, :test ] }
    # { :my_app:  path: "../my_app" },
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: ">= 1.9.1",
      deps: @deps,
      build_embedded: in_production
    ]
  end

  def application do
    [
      # built-in apps that need starting    
      extra_applications: [
        :logger
      ]
    ]
  end
end
