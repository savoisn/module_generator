defmodule ModuleGeneratorTest do
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

  test "create module test based on Module name without submodule" do
    root = File.cwd!()
    module_name = "MyModule"
    module_path = root <> "/test/my_module_test.exs"

    under_test = fn -> {:ok, ^module_path} = ModuleGenerator.createTestModule(module_name) end

    capture_io(under_test)

    assert File.exists?(module_path)
  end

  test "create module file based on Module name" do
    root = File.cwd!()
    module_name = "MyModule.MySubModule"
    module_path = root <> "/lib/my_module/my_sub_module.ex"

    under_test = fn -> {:ok, ^module_path} = ModuleGenerator.createModule(module_name) end
    capture_io(under_test)

    assert File.exists?(module_path)
  end

  test "create test file based on Module name" do
    root = File.cwd!()
    module_name = "MyModule.MySubModule"
    module_path = root <> "/test/my_module/my_sub_module_test.exs"

    under_test = fn -> {:ok, ^module_path} = ModuleGenerator.createTestModule(module_name) end
    capture_io(under_test)

    assert File.exists?(module_path)
  end

  test "files doesn't exists" do
    module_name = "MyModule.MySubModule"
    assert false == ModuleGenerator.filesAlreadyExists?(module_name)
  end

  test "return true if module exists" do
    module_name = "MyModule.MySubModule"
    under_test = fn -> {:ok, _} = ModuleGenerator.createModule(module_name) end
    capture_io(under_test)
    assert true == FileManager.fileModuleAlreadyExists?(module_name)
  end

  test "return true if test module exists" do
    module_name = "MyModule.MySubModule"
    under_test = fn -> {:ok, _} = ModuleGenerator.createTestModule(module_name) end
    capture_io(under_test)
    assert true == FileManager.fileTestModuleAlreadyExists?(module_name)
  end

  test "return true if both module exists" do
    module_name = "MyModule.MySubModule"
    under_test = fn -> {:ok, _} = ModuleGenerator.createModule(module_name) end
    capture_io(under_test)
    under_test = fn -> {:ok, _} = ModuleGenerator.createTestModule(module_name) end
    capture_io(under_test)
    assert true == ModuleGenerator.filesAlreadyExists?(module_name)
  end

  test "all together - passing case" do
    module_name = "MyModule.MySubModule"
    under_test = fn -> {:ok} = ModuleGenerator.generate(module_name) end
    capture_io(under_test)
  end

  test "all together - file already exists" do
    module_name = "MyModule.MySubModule"
    under_test = fn -> {:ok} = ModuleGenerator.generate(module_name) end
    capture_io(under_test)
  end

  ############################################################

  # stolen from pragdave/mix_generator (:thanks)
  # who stole it from 
  # stolen from mix/test/tasks/new

  defp assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end
end
