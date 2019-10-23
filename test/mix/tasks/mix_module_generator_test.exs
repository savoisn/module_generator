defmodule MixModuleGeneratorTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "mix gen_module" do
    module_name = "MyModule.MySubModule"

    in_tmp(%{
      setup: fn ->
        mix_new = fn -> Mix.Tasks.New.run(["dummy"]) end
        capture_io(mix_new)
        File.cd!(Path.join(File.cwd!(), "dummy"))
        under_test = fn -> Mix.Tasks.GenModule.run([module_name]) end
        capture_io(under_test)
      end,
      test: fn return_value ->
        ~w{ 
          lib/my_module/my_sub_module.ex
          test/my_module/my_sub_module_test.exs
              }
        |> Enum.each(&assert_file/1)

        assert_file("lib/my_module/my_sub_module.ex", ~r/defmodule #{module_name}/)
        assert_file("test/my_module/my_sub_module_test.exs", ~r/defmodule #{module_name}Test/)

        assert return_value ==
                 "Generating Module and Tests for MyModule.MySubModule\n\e[30m\e[32m* /tmp/module_generator_test/dummy/lib/my_module/my_sub_module.ex\e[0m\n\e[30m\e[32m* /tmp/module_generator_test/dummy/test/my_module/my_sub_module_test.exs\e[0m\n"
      end
    })
  end

  test "mix gen_module when file present" do
    module_name = "MyModule.MySubModule"

    in_tmp(%{
      setup: fn ->
        mix_new = fn -> Mix.Tasks.New.run(["dummy"]) end
        capture_io(mix_new)
        File.cd!(Path.join(File.cwd!(), "dummy"))
        add_module = fn -> {:ok, _} = ModuleGenerator.createModule(module_name) end
        capture_io(add_module)
        run_generator = fn -> Mix.Tasks.GenModule.run([module_name]) end
        capture_io(run_generator)
      end,
      test: fn _ ->
        ~w{ 
          lib/my_module/my_sub_module.ex
          test/my_module/my_sub_module_test.exs
              }
        |> Enum.each(&assert_file/1)

        assert_file("lib/my_module/my_sub_module.ex", ~r/defmodule #{module_name}/)
        assert_file("test/my_module/my_sub_module_test.exs", ~r/defmodule #{module_name}Test/)
      end
    })
  end

  ############################################################

  # stolen from pragdave/mix_generator (:thanks)
  # who stole it from 
  # stolen from mix/test/tasks/new

  defp assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end

  defp assert_file(file, matcher) when is_function(matcher, 1) do
    assert_file(file)
    matcher.(File.read!(file))
  end

  defp assert_file(file, match) do
    assert_file(file, &assert(&1 =~ match))
  end

  def in_tmp(%{setup: setup, test: tests}) do
    {:ok, current_path} = File.cwd()
    files_test_path = System.tmp_dir!() <> "/module_generator_test"
    File.rm_rf!(files_test_path)
    File.mkdir!(files_test_path)

    File.cd!(files_test_path, fn ->
      ret = setup.()
      tests.(ret)
    end)

    File.cd(current_path)
  end
end
