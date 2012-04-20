module Adapter
  module Asserts
    RequiredMethods = [:read, :write, :delete, :clear]

    def assert_valid_module(mod)
      assert_methods_defined(mod)
    end

    def assert_valid_adapter(name)
      raise Undefined.new(name) unless definitions.key?(name.to_sym)
    end

    def assert_methods_defined(mod)
      missing_methods = []
      RequiredMethods.each do |meth|
        missing_methods << meth unless mod.method_defined?(meth)
      end
      raise IncompleteAPI.new(missing_methods) unless missing_methods.empty?
    end
  end
end
