defmodule ModuleGenerator.StructGeneratorTest do
  alias ModuleGenerator.StructGenerator
  use ExUnit.Case
  # doctest StructGenerator

  import ExUnit.CaptureIO

  setup do
    {:ok, current_path} = File.cwd()
    files_test_path = System.tmp_dir!() <> "/struct_generator_test"
    File.rm_rf!(files_test_path)
    File.mkdir!(files_test_path)
    File.cd(files_test_path)

    mix_new = fn -> Mix.Tasks.New.run(["dummy"]) end
    capture_io(mix_new)

    assert_file("/tmp/struct_generator_test/dummy/mix.exs")
    File.cd(files_test_path <> "/dummy")

    on_exit(fn ->
      File.rm_rf(files_test_path)
      File.cd(current_path)
    end)
  end

  test "dummy test" do
    root = File.cwd!()
    module_name = "MyModule.MyStruct"
    module_path = root <> "/lib/my_module/my_struct.ex"
    fields = []
    under_test = fn -> {:ok, ^module_path} = StructGenerator.createStruct(module_name, fields) end
    capture_io(under_test)
  end

  defp assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end
end
