defmodule ModuleGenerator.TemplateTest do
  alias ModuleGenerator.Template

  use ExUnit.Case
  # doctest ModuleGenerator.Template

  setup do
    # do someting to setup test

    on_exit(fn ->
      # do something when test exits
      nil
    end)
  end

  test "struct template generator 2 fields test" do
    struct_name = "MyStruct"
    fields = ["field1:string", "field2:integer"]

    awaited_template = """
    defmodule MyStruct do
      defstruct field1: nil,
                field2: nil
      @type t() :: %__MODULE__{
              field1: String.t(),
              field2: integer()
            }
    end
    """

    assert Template.struct_template(struct_name, fields) == awaited_template
  end

  test "struct template generator 2 fields and enforce_keys test" do
    struct_name = "MyStruct"
    fields = ["*field1:string", "field2:integer"]

    awaited_template = """
    defmodule MyStruct do
      @enforce_keys [:field1]
      defstruct field1: nil,
                field2: nil
      @type t() :: %__MODULE__{
              field1: String.t(),
              field2: integer()
            }
    end
    """

    assert Template.struct_template(struct_name, fields) == awaited_template
  end

  test "struct template generator 3 fields and enforce_keys test" do
    struct_name = "MyStruct"
    fields = ["*field1:string", "field2:integer", "*field3:string"]

    awaited_template = """
    defmodule MyStruct do
      @enforce_keys [:field1, :field3]
      defstruct field1: nil,
                field2: nil,
                field3: nil
      @type t() :: %__MODULE__{
              field1: String.t(),
              field2: integer(),
              field3: String.t()
            }
    end
    """

    assert Template.struct_template(struct_name, fields) == awaited_template
  end

  test "get_mandatory_fields " do
    fields = ["*field1:string", "field2:integer"]
    Template.get_mandatory_fields(fields)
  end
end
