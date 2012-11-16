module Adapter
  module Defaults
    def fetch(key, default_attributes=nil, options = nil)
      read(key, options) || begin
        if block_given?
          yield(key)
        else
          default_attributes
        end
      end
    end

    def read_multiple(keys, options = nil)
      result = {}
      keys.each { |key| result[key] = read(key, options) }
      result
    end

    def key?(key, options = nil)
      !read(key, options).nil?
    end
  end
end
