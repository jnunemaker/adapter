module Adapter
  module Defaults
    def fetch(key, value=nil, &block)
      read(key) || begin
        value = block_given? ? yield(key) : value
        read(key) || value
      end
    end

    def key?(key)
      !read(key).nil?
    end

    def key_for(key)
      key
    end

    def encode(value)
      value
    end

    def decode(value)
      value
    end
  end
end
