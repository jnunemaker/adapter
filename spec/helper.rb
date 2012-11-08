$:.unshift(File.expand_path('../../lib', __FILE__))

require 'pathname'
require 'rubygems'
require 'bundler'

require 'adapter/spec/an_adapter'
require 'support/module_helpers'

Bundler.require(:default, :test)

RSpec.configure do |config|
  config.include(ModuleHelpers)
end
