defmodule Mix.Tasks.GenModule do
  @moduledoc File.read!(Path.join([__DIR__, "../../../README.md"]))

  use Mix.Task

  def run(args) do
    parse_command(args)
    |> run_command
  end

  def parse_command(["--help"]), do: :help
  def parse_command(["help"]), do: :help
  def parse_command(["-h"]), do: :help

  def parse_command([module_name]) do
    {:module, module_name}
  end

  defp usage() do
    IO.puts("USAGE:")

    IO.puts("mix gen_module MyModule.MySubModule")

    exit(:normal)
  end

  def run_command(:help) do
    usage()
  end

  def run_command({:module, module_name}) do
    IO.puts("generating module and tests")
    {:ok} = ModuleGenerator.generate(module_name)
  end
end
