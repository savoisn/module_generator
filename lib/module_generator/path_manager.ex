defmodule ModuleGenerator.PathManager do
  @moduledoc """
  Documentation for PathManager
  """

  def findRoot(path) when path == "/" do
    case File.exists?(Path.join(path, "mix.exs")) do
      true -> {:ok, path}
      false -> {:ko, :enoent}
    end
  end

  def findRoot(path) do
    mixExists = File.exists?(Path.join(path, "mix.exs"))

    case mixExists do
      true -> {:ok, path}
      false -> findRoot(Path.dirname(path))
    end
  end

  def convertModuleNameToPath(module_name) do
    constructPathFromModule(module_name) <> ".ex"
  end

  def convertModuleNameToTestPath(module_name) do
    constructPathFromModule(module_name) <> "_test.exs"
  end

  def constructPathFromModule(module_name) do
    charlist = String.codepoints(module_name)

    newcharlist =
      Stream.with_index(charlist, 0)
      |> Enum.map(fn {char, index} ->
        convertChar(char, index)
      end)

    # correct the /_
    module_path = List.to_string(newcharlist)
    regex = ~r/\/_/
    Regex.replace(regex, module_path, "/")
  end

  def convertChar(char, 0) do
    String.downcase(char)
  end

  def convertChar(char, _) when char == "." do
    "/"
  end

  def convertChar(char, _) do
    case char =~ ~r/^\p{Lu}$/u do
      true -> String.downcase("_" <> char)
      false -> char
    end
  end

  def getFilePath(module_path, folder) do
    case findRoot(File.cwd!()) do
      {:ok, root} ->
        lib_path = Path.join(root, folder)
        {:ok, Path.join(lib_path, module_path)}

      {:ko, :enoent} ->
        {:ko, :not_a_mix_project}
    end
  end
end
