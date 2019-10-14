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
    corrected_module_path = Regex.replace(regex, module_path, "/")
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
    IO.puts(IO.ANSI.format([:black, :green, "* #{Path.join("lib", module_path)}"]))

    createFile(
      module_name,
      module_path,
      "/lib",
      Template.module_template(module_name)
    )
  end

  def createTestModule(module_name) do
    test_path = convertModuleNameToTestPath(module_name)
    IO.puts(IO.ANSI.format([:black, :green, "* #{Path.join("test", test_path)}"]))

    createFile(
      module_name,
      test_path,
      "/test",
      Template.test_template(module_name)
    )
  end

  def createFile(module_name, module_path, folder, template) do
    case findRoot(File.cwd!()) do
      {:ok, root} ->
        lib_path = root <> folder <> "/"
        module_path = lib_path <> module_path
        File.mkdir_p!(Path.dirname(module_path))
        File.write!(module_path, template)
        {:ok, module_path}

      {:ko, :enoent} ->
        {:ko, :not_a_mix_project}
    end
  end

  def filesAlreadyExists?(module_name) do
    case findRoot(File.cwd!()) do
      {:ok, root} ->
        lib_path = root <> "/lib/"
        test_path = root <> "/test/"
        module_path = convertModuleNameToPath(module_name)
        test_module_path = convertModuleNameToTestPath(module_name)
        full_module_path = lib_path <> module_path
        full_test_path = test_path <> test_module_path
        File.exists?(full_module_path) || File.exists?(full_test_path)

      {:ko, :enoent} ->
        {:ko, :not_a_mix_project}
    end
  end

  def generate(module_name) do
    case filesAlreadyExists?(module_name) do
      false ->
        {:ok, _} = createModule(module_name)
        {:ok, _} = createTestModule(module_name)
        {:ok}

      true ->
        {:ko, "Files already Exist"}
    end
  end
end
