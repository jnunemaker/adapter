$:.unshift(File.expand_path('../../lib', __FILE__))

require 'pathname'
require 'rubygems'
require 'bundler'

require 'adapter/spec/an_adapter'
require 'support/module_helpers'

Bundler.require(:default, :test)

Rspec.configure do |c|
  c.include(ModuleHelpers)
end
