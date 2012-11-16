# Changelog

## 0.7.0

* `key_for`, `encode` and `decode` are no longer provided or necessary.
* All methods must accept options as last parameter. They do not need to do anything with them, but they must at least be declared.
* Tightened up API. `get`, `set`, `[]`, `[]=`, and `get_multiple` are now gone.

## 0.6.0

* Now aimed at key/value where value is Hash of attributes instead of just any random value, such as String, Array, etc.
* `#key_for` now defaults to whatever was passed in, rather than Marshaling anything that was not a String or a Symbol.
* `#encode` and `#decode` now default to whatever was passed in, instead of marshaling.
* `#delete` no longer returns value. Raise error if delete fails. If you need value, do a read before delete.
* Added `#read_multiple`. This can be overridden per adapter to make it more efficient based on the data store. Defaults to multiple single reads.
