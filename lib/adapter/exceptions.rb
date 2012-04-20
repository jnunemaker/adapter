module Adapter
  class Error < StandardError; end

  class Undefined < Error; end

  class IncompleteAPI < Error
    def initialize(methods)
      super("Missing methods needed to complete API (#{methods.join(', ')})")
    end
  end

  class LockTimeout < Error
    def initialize(key, timeout)
      super("Timeout on lock #{key} exceeded #{timeout} sec")
    end
  end
end
