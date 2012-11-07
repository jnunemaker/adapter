# encoding: UTF-8
require File.expand_path('../lib/adapter/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'adapter'
  s.homepage     = 'http://github.com/jnunemaker/adapter'
  s.summary      = 'A simple interface to anything'
  s.require_paths = ["lib"]
  s.authors      = ['John Nunemaker', 'Geoffrey Dagley', 'Brandon Keepers']
  s.email        = ['nunemaker@gmail.com', 'gdagley@gmail.com', 'brandon@opensoul.org']
  s.version      = Adapter::VERSION
  s.platform     = Gem::Platform::RUBY
  s.files        = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
end
