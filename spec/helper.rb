$:.unshift(File.expand_path('../../lib', __FILE__))

require 'pathname'

require 'adapter/spec/an_adapter'
require 'adapter/spec/marshal_adapter'
require 'adapter/spec/types'
require 'support/module_helpers'

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

Rspec.configure do |c|
  c.include(ModuleHelpers)
end
