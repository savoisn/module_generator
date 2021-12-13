defmodule ModuleGenerator.StructGenerator do
  alias ModuleGenerator.PathManager
  alias ModuleGenerator.FileManager
  alias ModuleGenerator.Template

  def createStruct(struct_name, struct_fields) do
    struct_path = PathManager.convertModuleNameToPath(struct_name)

    case PathManager.getFilePath(struct_path, "lib") do
      {:ok, full_struct_path} ->
        template = Template.struct_template(struct_name, struct_fields)
        FileManager.createFileIfNotExist(full_struct_path, template)

      {:ko, :not_a_mix_project} ->
        {:ko, :not_a_mix_project}
    end
  end
end
