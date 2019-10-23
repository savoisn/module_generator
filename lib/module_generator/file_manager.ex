defmodule ModuleGenerator.FileManager do
  alias ModuleGenerator.PathManager

  @moduledoc """
  Documentation for ModuleGenerator.FileManager
  """

  def createFileIfNotExist(module_path, template) do
    case not File.exists?(module_path) do
      true ->
        IO.puts(IO.ANSI.format([:black, :green, "* #{module_path}"]))

        createFile(module_path, template)

      false ->
        IO.puts(IO.ANSI.format([:black, :yellow, "* #{module_path} - ignored"]))
        {:ok, :ignored}
    end
  end

  def createFile(module_path, template) do
    File.mkdir_p!(Path.dirname(module_path))
    File.write!(module_path, template)
    {:ok, module_path}
  end

  def fileModuleAlreadyExists?(module_name) do
    case PathManager.findRoot(File.cwd!()) do
      {:ok, root} ->
        module_path = PathManager.convertModuleNameToPath(module_name)
        lib_path = Path.join(root, "/lib/")
        full_module_path = Path.join(lib_path, module_path)
        File.exists?(full_module_path)

      {:ko, :enoent} ->
        {:ko, :not_a_mix_project}
    end
  end

  def fileTestModuleAlreadyExists?(module_name) do
    case PathManager.findRoot(File.cwd!()) do
      {:ok, root} ->
        module_path = PathManager.convertModuleNameToTestPath(module_name)
        lib_path = Path.join(root, "/test/")
        full_module_path = Path.join(lib_path, module_path)
        File.exists?(full_module_path)

      {:ko, :enoent} ->
        {:ko, :not_a_mix_project}
    end
  end
end
