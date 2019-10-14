defmodule Template do
  def module_template(module_name) do
    """
      defmodule #{module_name} do
        def hello do
          :world
        end
      end
    """
  end

  def test_template(module_name) do
    """
      defmodule #{module_name}_test do
        
        use ExUnit.Case
        # doctest ModuleGenerator

        setup do
          #do someting to setup test

          on_exit(fn ->
            #do something when test exits
          end)
        end

        test "hello world test" do
          assert #{module_name}.hello() == :world
        end
        
      end
    """
  end
end
