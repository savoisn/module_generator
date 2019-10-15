defmodule ModuleGenerator do
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

  def createModule(module_name) do
    module_path = convertModuleNameToPath(module_name)

    case getFilePath(module_path, "lib") do
      {:ok, full_module_path} ->
        template = Template.module_template(module_name)
        createFileIfNotExist(full_module_path, template)

      {:ko, :not_a_mix_project} ->
        {:ko, :not_a_mix_project}
    end
  end

  def createTestModule(module_name) do
    test_path = convertModuleNameToTestPath(module_name)

    case getFilePath(test_path, "test") do
      {:ok, test_module_path} ->
        template = Template.test_template(module_name)
        createFileIfNotExist(test_module_path, template)

      {:ko, :not_a_mix_project} ->
        {:ko, :not_a_mix_project}
    end
  end

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

  def getFilePath(module_path, folder) do
    case findRoot(File.cwd!()) do
      {:ok, root} ->
        lib_path = Path.join(root, folder)
        {:ok, Path.join(lib_path, module_path)}

      {:ko, :enoent} ->
        {:ko, :not_a_mix_project}
    end
  end

  def fileModuleAlreadyExists?(module_name) do
    case findRoot(File.cwd!()) do
      {:ok, root} ->
        module_path = convertModuleNameToPath(module_name)
        lib_path = Path.join(root, "/lib/")
        full_module_path = Path.join(lib_path, module_path)
        File.exists?(full_module_path)

      {:ko, :enoent} ->
        {:ko, :not_a_mix_project}
    end
  end

  def fileTestModuleAlreadyExists?(module_name) do
    case findRoot(File.cwd!()) do
      {:ok, root} ->
        module_path = convertModuleNameToTestPath(module_name)
        lib_path = Path.join(root, "/test/")
        full_module_path = Path.join(lib_path, module_path)
        File.exists?(full_module_path)

      {:ko, :enoent} ->
        {:ko, :not_a_mix_project}
    end
  end

  def filesAlreadyExists?(module_name) do
    fileModuleAlreadyExists?(module_name) && fileTestModuleAlreadyExists?(module_name)
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
