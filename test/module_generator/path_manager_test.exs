defmodule ModuleGenerator.PathManagerTest do
  alias ModuleGenerator.PathManager
  use ExUnit.Case
  # doctest PathManager

  setup do
    # do someting to setup test

    on_exit(fn ->
      # do something when test exits
      nil
    end)
  end

  test "find mix.exs file and return root path" do
    root = File.cwd!()

    assert PathManager.findRoot(root) == {:ok, root}

    lib = File.cwd!() <> "/lib"
    assert PathManager.findRoot(lib) == {:ok, root}

    test_path = File.cwd!() <> "/test"
    assert PathManager.findRoot(test_path) == {:ok, root}

    no_good_path = "/tmp"
    assert PathManager.findRoot(no_good_path) == {:ko, :enoent}
  end

  test "convert ModuleName to path" do
    module_name = "MyModyle.MySubModule"
    module_path = "my_modyle/my_sub_module.ex"

    ^module_path = PathManager.convertModuleNameToPath(module_name)
  end

  test "construct path single module" do
    module_name = "MySubModule"
    module_path = "my_sub_module"
    ^module_path = PathManager.constructPathFromModule(module_name)
  end

  test "construct path single_module and submodule" do
    module_name = "MyModyle.MySubModule"
    module_path = "my_modyle/my_sub_module"
    ^module_path = PathManager.constructPathFromModule(module_name)
  end

  test "construct path single_module and submodule and numbers" do
    module_name = "MyModyle.MySubModule03"
    module_path = "my_modyle/my_sub_module_03"
    ^module_path = PathManager.constructPathFromModule(module_name)
  end
end
