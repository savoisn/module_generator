defmodule ModuleGenerator.FileManagerTest do
  use ExUnit.Case
  # doctest ModuleGenerator.FileManager

  import ExUnit.CaptureIO

  setup do
    {:ok, current_path} = File.cwd()
    files_test_path = System.tmp_dir!() <> "/module_file_generator_test"
    File.rm_rf!(files_test_path)
    File.mkdir!(files_test_path)
    File.cd(files_test_path)

    mix_new = fn -> Mix.Tasks.New.run(["dummy"]) end
    capture_io(mix_new)

    assert_file("/tmp/module_file_generator_test/dummy/mix.exs")
    File.cd(files_test_path <> "/dummy")

    on_exit(fn ->
      File.rm_rf(files_test_path)
      File.cd(current_path)
    end)
  end

  defp assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end
end
