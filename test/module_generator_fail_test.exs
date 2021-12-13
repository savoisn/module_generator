defmodule ModuleGeneratorFailTest do
  alias ModuleGenerator.FileManager
  use ExUnit.Case
  # doctest ModuleGenerator
  import ExUnit.CaptureIO

  setup do
    {:ok, current_path} = File.cwd()
    files_test_path = System.tmp_dir!() <> "/module_generator_test"
    File.rm_rf!(files_test_path)
    File.mkdir!(files_test_path)
    File.cd(files_test_path)

    mix_new = fn -> Mix.Tasks.New.run(["dummy"]) end
    capture_io(mix_new)

    assert_file("/tmp/module_generator_test/dummy/mix.exs")
    File.cd(files_test_path <> "/dummy")

    on_exit(fn ->
      File.rm_rf(files_test_path)
      File.cd(current_path)
    end)
  end

  test "create module file based on Module name without submodule" do
    root = File.cwd!()
    module_name = "MyModule"
    module_path = root <> "/lib/my_module.ex"

    under_test = fn -> {:ok, ^module_path} = ModuleGenerator.createModule(module_name) end
    capture_io(under_test)

    assert File.exists?(module_path)
  end

  ############################################################

  # stolen from pragdave/mix_generator (:thanks)
  # who stole it from 
  # stolen from mix/test/tasks/new

  defp assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end
end
