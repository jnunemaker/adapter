module Adapter
  module Defaults
    def fetch(key, attributes=nil)
      read(key) || begin
        if block_given?
          yield(key)
        else
          attributes
        end
      end
    end

    def read_multiple(*keys)
      result = {}
      keys.each { |key| result[key_for(key)] = read(key) }
      result
    end

    def key?(key)
      !read(key).nil?
    end

    def key_for(key)
      key
    end

    def encode(attributes)
      attributes
    end

    def decode(attributes)
      attributes
    end
  end
end
