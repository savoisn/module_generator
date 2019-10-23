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

  def struct_template(struct_name) do
    """
    defmodule #{struct_name} do
      defstruct value: nil

      @type t() :: %__MODULE__{
              value: integer()
            }
      
    end
    """
  end
end
