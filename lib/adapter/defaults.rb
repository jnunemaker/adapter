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
      if key.is_a?(String)
        key
      elsif key.is_a?(Symbol)
        key.to_s
      else
        Marshal.dump(key)
      end
    end

    def encode(value)
      Marshal.dump(value)
    end

    def decode(value)
      value && Marshal.load(value)
    end
  end
end
