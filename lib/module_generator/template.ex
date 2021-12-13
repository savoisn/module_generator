defmodule ModuleGenerator.Template do
  def module_template(module_name) do
    """
    defmodule #{module_name} do
      @moduledoc \"""
      Documentation for #{module_name}
      \"""

      @doc \"""
      Hello world.

      ## Examples

          iex> #{module_name}.dummy()
          :world

      \"""
      def dummy do
        :foo
      end
    end
    """
  end

  def test_template(module_name) do
    """
    defmodule #{module_name}Test do
      
      use ExUnit.Case
      # doctest #{module_name}

      setup do
        #do someting to setup test

        on_exit(fn ->
          #do something when test exits
          nil
        end)
      end

      test "dummy test" do
        assert #{module_name}.dummy() == :foo
      end
      
    end
    """
  end

  def struct_template(struct_name, fields) do
    """
    defmodule #{struct_name} do#{get_enforced_keys(fields)}
      defstruct #{get_fields(fields)}
      @type t() :: %__MODULE__{
              #{get_fields_types(fields)}
            }
    end
    """
  end

  def get_enforced_keys(fields) do
    case get_mandatory_fields(fields) do
      "" -> nil
      str_fields -> "\n  @enforce_keys [#{str_fields}]"
    end
  end

  def get_mandatory_fields(fields) do
    result =
      Enum.reduce(fields, "", fn item, acc ->
        [field_name, _type] = String.split(item, ":")

        if String.starts_with?(field_name, "*") do
          "#{acc}:#{String.slice(field_name, 1..-1)}, "
        else
          acc
        end
      end)

    # ugly but fast to implement
    String.slice(result, 0..-3)
  end

  def get_fields(fields) do
    Enum.map_join(fields, ",\n            ", fn item ->
      [field_name, _type] = String.split(item, ":")
      "#{stripchars(field_name, "*")}: nil"
    end)
  end

  def get_fields_types(fields) do
    Enum.map_join(fields, ",\n          ", fn item ->
      [field_name, type] = String.split(item, ":")
      "#{stripchars(field_name, "*")}: #{get_type(type)}"
    end)
  end

  def stripchars(str, chars) do
    String.replace(str, ~r/[#{chars}]/, "")
  end

  def get_type(type) do
    case type do
      "integer" -> "integer()"
      "string" -> "String.t()"
      _ -> "#{type}.t()"
    end
  end
end
