defmodule ModuleGenerator do
  alias ModuleGenerator.Template
  alias ModuleGenerator.PathManager
  alias ModuleGenerator.FileManager

  def createModule(module_name) do
    module_path = PathManager.convertModuleNameToPath(module_name)

    case PathManager.getFilePath(module_path, "lib") do
      {:ok, full_module_path} ->
        template = Template.module_template(module_name)
        FileManager.createFileIfNotExist(full_module_path, template)

      {:ko, :not_a_mix_project} ->
        {:ko, :not_a_mix_project}
    end
  end

  def createTestModule(module_name) do
    test_path = PathManager.convertModuleNameToTestPath(module_name)

    case PathManager.getFilePath(test_path, "test") do
      {:ok, test_module_path} ->
        template = Template.test_template(module_name)
        FileManager.createFileIfNotExist(test_module_path, template)

      {:ko, :not_a_mix_project} ->
        {:ko, :not_a_mix_project}
    end
  end

  def filesAlreadyExists?(module_name) do
    FileManager.fileModuleAlreadyExists?(module_name) &&
      FileManager.fileTestModuleAlreadyExists?(module_name)
  end

  def generate(module_name) do
    case not filesAlreadyExists?(module_name) do
      true ->
        {:ok, _} = createModule(module_name)
        {:ok, _} = createTestModule(module_name)

      false ->
        IO.puts(IO.ANSI.format([:black, :red, "File already exists"]))
    end

    {:ok}
  end
end
