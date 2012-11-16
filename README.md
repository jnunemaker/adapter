# Adapter

A simple interface to anything.

## Defining an Adapter

An adapter requires 4 methods to work: read, write, delete and clear.

```ruby
Adapter.define(:memory) do
  def read(key, options = nil)
    client[key]
  end

  def write(key, attributes, options = nil)
    client[key] = attributes
  end

  def delete(key, options = nil)
    client.delete(key)
  end

  def clear(options = nil)
    client.clear
  end
end
```

Note: in order for things to be most flexible, always wrap key with key_for(key) which will ensure that pretty much anything can be a key. Also, by default encode and decode are included and they Marshal.dump and Marshal.load. Feel free to override these if you prefer JSON serialization or something else.

Once you have defined an adapter, you can get a class of that adapter like this:

```ruby
Adapter[:memory]
```

This returns a dynamic class with your adapting methods included and an initialize method that takes a client. This means you can get an instance of the adapter by using new and passing the client (in this instance a boring hash):

```ruby
adapter = Adapter[:memory].new({}) # sets {} to client
adapter.write('foo', 'bar')
adapter.read('foo') # 'bar'
adapter.delete('foo')
adapter.fetch('foo', 'bar') # returns bar and sets foo to bar
```

Note: You can also optionally provide a lock method. [Read More](https://github.com/jnunemaker/adapter/wiki/Locking)

## Adapter Power User Guides

* [Wiki Home](https://github.com/jnunemaker/adapter/wiki)
* [Creating an Adapter](https://github.com/jnunemaker/adapter/wiki/Creating-an-Adapter)
* [Overriding an Adapter](https://github.com/jnunemaker/adapter/wiki/Overriding-an-Adapter)
* [Allowing for Options](https://github.com/jnunemaker/adapter/wiki/Allowing-for-Options)
* [Adapter defaults](https://github.com/jnunemaker/adapter/wiki/Adapter-defaults)

## Mailing List

https://groups.google.com/forum/#!forum/toystoreadapter

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix in a topic branch.
* Add tests for it. This is important so we don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine, but bump version in a commit by itself so we can ignore when we pull)
* Send a pull request.
